(function () {
  var root = document.documentElement;
  var toggleButton;
  var STORAGE_KEY = "flipzon-theme";

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    localStorage.setItem(STORAGE_KEY, theme);
    if (toggleButton) {
      toggleButton.setAttribute("data-theme-state", theme);
      toggleButton.setAttribute("aria-label", theme === "dark" ? "Switch to Light Mode" : "Switch to Dark Mode");
    }
  }

  function initTheme() {
    var stored = localStorage.getItem(STORAGE_KEY);
    var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    var initial = stored || (prefersDark ? "dark" : "light");
    applyTheme(initial);

    toggleButton = document.querySelector("[data-theme-toggle]");
    if (!toggleButton) {
      return;
    }

    toggleButton.addEventListener("click", function (e) {
      e.preventDefault();
      var current = root.getAttribute("data-theme") || "light";
      applyTheme(current === "dark" ? "light" : "dark");
    });

    // Prevent double-click text selection
    toggleButton.addEventListener("dblclick", function (e) {
      e.preventDefault();
    });
  }

  document.addEventListener("DOMContentLoaded", initTheme);
})();
