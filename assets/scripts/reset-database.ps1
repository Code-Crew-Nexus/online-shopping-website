param(
    [string]$ConfigPath = "",
    [string]$LocalConfigPath = "",
    [string]$RootUser = "",
    [string]$RootPassword = "",
    [string]$DbHost = "",
    [int]$Port = 0,
    [string]$DbName = "",
    [switch]$IncludeAdmins,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

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

$config = @{
    db_host = "localhost"
    db_port = 3306
    db_name = "flipzon_shop"
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

$RootUser = [string]$config.root_user
$DbHost = [string]$config.db_host
$Port = [int]$config.db_port
$DbName = [string]$config.db_name

$validNamePattern = '^[a-zA-Z0-9_]+$'
if ($DbName -notmatch $validNamePattern) {
    Write-Error "DbName can only contain letters, numbers, and underscore."
    exit 1
}

if (-not $Force) {
    Write-Host "WARNING: This will permanently delete user-generated data from '$DbName'." -ForegroundColor Yellow
    if ($IncludeAdmins) {
        Write-Host "It will delete ALL users (including admins) and ALL orders." -ForegroundColor Yellow
    } else {
        Write-Host "It will delete USER role accounts and ALL orders." -ForegroundColor Yellow
    }

    $confirmation = Read-Host "Type RESET to continue"
    if ($confirmation -ne "RESET") {
        Write-Host "Cancelled. No data was changed." -ForegroundColor Cyan
        exit 0
    }
}

$deleteUsersSql = if ($IncludeAdmins) {
    "DELETE FROM users;"
} else {
    "DELETE FROM users WHERE UPPER(COALESCE(role, 'USER')) = 'USER';"
}

$sql = @"
USE $DbName;
START TRANSACTION;

DELETE FROM orders;
$deleteUsersSql

ALTER TABLE orders AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;

COMMIT;

SELECT 'orders_remaining' AS metric, COUNT(*) AS value FROM orders
UNION ALL
SELECT 'users_remaining', COUNT(*) FROM users;
"@

if ($DryRun) {
    Write-Host "Dry run enabled. SQL to be executed:" -ForegroundColor Cyan
    Write-Output $sql
    exit 0
}

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

$tempFile = Join-Path $env:TEMP "flipzon_shop_reset.sql"
Set-Content -Path $tempFile -Value $sql -Encoding UTF8

try {
    Write-Host "Resetting user-generated data in '$DbName'..." -ForegroundColor Cyan
    Get-Content -Path $tempFile | mysql --protocol=tcp -h $DbHost -P $Port -u $RootUser "-p$RootPassword"
    if ($LASTEXITCODE -ne 0) {
        throw "MySQL command failed with exit code $LASTEXITCODE."
    }

    Write-Host "Reset complete." -ForegroundColor Green
    Write-Host "Orders cleared and user-entered accounts removed." -ForegroundColor Green
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}
