param(
    [string]$ConfigPath = "",
    [string]$LocalConfigPath = "",
    [string]$ProductsPath = "",
    [string]$RootUser = "",
    [string]$RootPassword = "",
    [string]$DbHost = "",
    [int]$Port = 0,
    [string]$DbName = "",
    [string]$AppUser = "",
    [string]$AppPassword = ""
)

$ErrorActionPreference = "Stop"

function Escape-SqlString {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

function Merge-Config {
    param(
        [hashtable]$Target,
        [pscustomobject]$Source
    )

    foreach ($property in $Source.PSObject.Properties) {
        $Target[$property.Name] = $property.Value
    }
}

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "database.txt"
}

if ([string]::IsNullOrWhiteSpace($LocalConfigPath)) {
    $LocalConfigPath = Join-Path $PSScriptRoot "database.local.txt"
}

if ([string]::IsNullOrWhiteSpace($ProductsPath)) {
    $ProductsPath = Join-Path (Join-Path $PSScriptRoot "..") "data\\products.json"
}

$config = @{
    db_host = "localhost"
    db_port = 3306
    db_name = "flipzon_shop"
    app_user = "flipzon_app"
    app_password = "flipzon_app_password"
    root_user = "root"
}

if (Test-Path $ConfigPath) {
    Merge-Config -Target $config -Source ((Get-Content $ConfigPath -Raw) | ConvertFrom-Json)
}

if (Test-Path $LocalConfigPath) {
    Merge-Config -Target $config -Source ((Get-Content $LocalConfigPath -Raw) | ConvertFrom-Json)
}

if (-not [string]::IsNullOrWhiteSpace($RootUser)) { $config.root_user = $RootUser }
if (-not [string]::IsNullOrWhiteSpace($DbHost)) { $config.db_host = $DbHost }
if ($Port -gt 0) { $config.db_port = $Port }
if (-not [string]::IsNullOrWhiteSpace($DbName)) { $config.db_name = $DbName }
if (-not [string]::IsNullOrWhiteSpace($AppUser)) { $config.app_user = $AppUser }
if (-not [string]::IsNullOrWhiteSpace($AppPassword)) { $config.app_password = $AppPassword }

$RootUser = [string]$config.root_user
$DbHost = [string]$config.db_host
$Port = [int]$config.db_port
$DbName = [string]$config.db_name
$AppUser = [string]$config.app_user
$AppPassword = [string]$config.app_password

if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Error "MySQL CLI (mysql) is not found in PATH. Install MySQL client and try again."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($RootPassword)) {
    $securePassword = Read-Host "Enter MySQL root/admin password" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $RootPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

$validNamePattern = '^[a-zA-Z0-9_]+$'
if ($DbName -notmatch $validNamePattern) {
    Write-Error "DbName can only contain letters, numbers, and underscore."
    exit 1
}

if ($AppUser -notmatch $validNamePattern) {
    Write-Error "AppUser can only contain letters, numbers, and underscore."
    exit 1
}

$dbNameSql = Escape-SqlString $DbName
$appUserSql = Escape-SqlString $AppUser
$appPassSql = Escape-SqlString $AppPassword
$productSeedSql = ""

if (Test-Path $ProductsPath) {
    $products = (Get-Content $ProductsPath -Raw) | ConvertFrom-Json
    $rows = @()
    foreach ($product in $products) {
        $nameSql = Escape-SqlString([string]$product.name)
        $descriptionSql = Escape-SqlString([string]$product.description)
        $imageSql = Escape-SqlString([string]$product.imageUrl)
        $priceSql = [string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0:0.##}", [decimal]$product.price)
        $rows += "($([int]$product.id), '$nameSql', $priceSql, '$descriptionSql', '$imageSql')"
    }

    if ($rows.Count -gt 0) {
        $productSeedSql = @"

INSERT INTO products (id, name, price, description, image_url)
VALUES
    $($rows -join ",`n    ")
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    price = VALUES(price),
    description = VALUES(description),
    image_url = VALUES(image_url);
"@
    }
}

$sql = @"
CREATE DATABASE IF NOT EXISTS $dbNameSql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '$appUserSql'@'localhost' IDENTIFIED BY '$appPassSql';
GRANT ALL PRIVILEGES ON $dbNameSql.* TO '$appUserSql'@'localhost';
FLUSH PRIVILEGES;

USE $dbNameSql;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'USER'
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_group_id VARCHAR(50) NOT NULL,
    p_id INT NOT NULL,
    u_id INT NOT NULL,
    o_quantity INT NOT NULL,
    o_date VARCHAR(20) NOT NULL,
    o_address VARCHAR(255),
    order_status VARCHAR(20) DEFAULT 'Delivered',
    FOREIGN KEY (p_id) REFERENCES products(id),
    FOREIGN KEY (u_id) REFERENCES users(id),
    INDEX idx_order_group (order_group_id),
    INDEX idx_user_date (u_id, o_date)
);
$productSeedSql
"@

$tempFile = Join-Path $env:TEMP "flipzon_shop_setup.sql"
Set-Content -Path $tempFile -Value $sql -Encoding UTF8

try {
    Write-Host "Creating database and tables..." -ForegroundColor Cyan
    Get-Content -Path $tempFile | mysql --protocol=tcp -h $DbHost -P $Port -u $RootUser "-p$RootPassword"
    if ($LASTEXITCODE -ne 0) {
        throw "MySQL command failed with exit code $LASTEXITCODE. Check credentials/host/port and try again."
    }

    Write-Host "Database setup completed." -ForegroundColor Green
    if ($productSeedSql) {
        Write-Host "Product catalog seeded into MySQL." -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "Use these environment variables for the app:" -ForegroundColor Yellow
    Write-Host "  SHOP_DB_HOST=$DbHost"
    Write-Host "  SHOP_DB_PORT=$Port"
    Write-Host "  SHOP_DB_NAME=$DbName"
    Write-Host "  SHOP_DB_USER=$AppUser"
    Write-Host "  SHOP_DB_PASSWORD=$AppPassword"
    Write-Host ""
    Write-Host "Persist variables (new terminal required):" -ForegroundColor Yellow
    Write-Host "  setx SHOP_DB_HOST $DbHost"
    Write-Host "  setx SHOP_DB_PORT $Port"
    Write-Host "  setx SHOP_DB_NAME $DbName"
    Write-Host "  setx SHOP_DB_USER $AppUser"
    Write-Host "  setx SHOP_DB_PASSWORD $AppPassword"
    Write-Host ""
    Write-Host "Shared config comes from $ConfigPath" -ForegroundColor DarkGray
    Write-Host "Optional machine-specific override: $LocalConfigPath" -ForegroundColor DarkGray
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}
