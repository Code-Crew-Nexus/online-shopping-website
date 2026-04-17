(function () {
  var root = document.documentElement;
  var toggleButton;
  var STORAGE_KEY = "flipzon-theme";
  var EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

  function updateThemeLogos(theme) {
    var logos = document.querySelectorAll("[data-theme-logo]");
    logos.forEach(function (logo) {
      var lightSrc = logo.getAttribute("data-logo-light");
      var darkSrc = logo.getAttribute("data-logo-dark");
      if (!lightSrc || !darkSrc) {
        return;
      }

      var nextSrc = theme === "dark" ? darkSrc : lightSrc;
      if (logo.getAttribute("src") !== nextSrc) {
        logo.setAttribute("src", nextSrc);
      }
    });
  }

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    localStorage.setItem(STORAGE_KEY, theme);
    updateThemeLogos(theme);
    if (toggleButton) {
      toggleButton.setAttribute("data-theme-state", theme);
      toggleButton.setAttribute("data-current-mode", theme === "dark" ? "dark" : "light");
      toggleButton.setAttribute("title", theme === "dark" ? "Dark mode" : "Light mode");
      toggleButton.setAttribute("aria-label", theme === "dark" ? "Switch to Light Mode" : "Switch to Dark Mode");
    }
  }

  function initTheme() {
    toggleButton = document.querySelector("[data-theme-toggle]");

    var stored = localStorage.getItem(STORAGE_KEY);
    var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    var initial = stored || (prefersDark ? "dark" : "light");
    applyTheme(initial);

    if (!toggleButton) {
      return;
    }

    // Force this control to render as a pure icon toggle (no visible text).
    toggleButton.textContent = "";

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

  function debounce(fn, wait) {
    var timerId;
    return function () {
      var args = arguments;
      var context = this;
      clearTimeout(timerId);
      timerId = setTimeout(function () {
        fn.apply(context, args);
      }, wait);
    };
  }

  function getEmailCheckUrl(email) {
    return "check-email?email=" + encodeURIComponent(email);
  }

  function initLiveEmailValidation(inputSelector, feedbackSelector, passwordSelector, validMessage, invalidMessage) {
    var emailInput = document.querySelector(inputSelector);
    var feedback = document.querySelector(feedbackSelector);
    var passwordInput = document.querySelector(passwordSelector);

    if (!emailInput || !feedback || !passwordInput) {
      return;
    }

    var passwordPlaceholder = passwordInput.getAttribute("placeholder");

    function showPasswordPrompt(event) {
      var value = emailInput.value.trim();
      if (EMAIL_PATTERN.test(value)) {
        return;
      }

      if (event) {
        event.preventDefault();
        event.stopPropagation();
      }

      window.alert("Enter a Valid Email first");
      passwordInput.blur();
    }

    function setPasswordState(isEnabled) {
      passwordInput.readOnly = !isEnabled;
      passwordInput.setAttribute("aria-disabled", String(!isEnabled));
      passwordInput.setAttribute(
        "placeholder",
        isEnabled ? passwordPlaceholder : "Enter a valid email first"
      );
      passwordInput.setAttribute(
        "title",
        isEnabled ? "" : "Enter a valid email address first to enable this field."
      );

      if (!isEnabled) {
        passwordInput.value = "";
      }
    }

    setPasswordState(false);

    function renderMessage() {
      var value = emailInput.value.trim();
      var isValid = EMAIL_PATTERN.test(value);

      feedback.classList.remove("is-invalid", "is-valid");

      setPasswordState(isValid);

      if (!value) {
        feedback.textContent = "";
        return;
      }

      if (isValid) {
        feedback.textContent = validMessage;
        feedback.classList.add("is-valid");
      } else {
        feedback.textContent = invalidMessage;
        feedback.classList.add("is-invalid");
      }
    }

    emailInput.addEventListener("input", renderMessage);
    emailInput.addEventListener("blur", renderMessage);

    passwordInput.addEventListener("pointerdown", showPasswordPrompt);
    passwordInput.addEventListener("focus", showPasswordPrompt);

    renderMessage();
  }

  function initRegisterEmailAvailability() {
    var emailInput = document.querySelector("[data-register-email]");
    var feedback = document.querySelector("[data-register-email-feedback]");
    var passwordInput = document.querySelector("[data-register-password]");
    var form = document.querySelector(".auth-form[action$='/register']");
    var submitButton = document.querySelector("[data-register-submit]");
    var passwordPlaceholder = passwordInput ? passwordInput.getAttribute("placeholder") : "Password (min 6 characters)";

    if (!emailInput || !feedback || !passwordInput || !form) {
      return;
    }

    var lastCheckedEmail = "";
    var accountExists = false;
    var accountCheckInFlight = false;
    var activeController = null;
    var promptedForEmail = "";

    function setPasswordState(isEnabled) {
      passwordInput.readOnly = !isEnabled;
      passwordInput.setAttribute("aria-disabled", String(!isEnabled));
      passwordInput.setAttribute(
        "placeholder",
        isEnabled ? passwordPlaceholder : "Enter a valid email first"
      );
      passwordInput.setAttribute(
        "title",
        isEnabled ? "" : "Enter a valid email address first to enable this field."
      );

      if (!isEnabled) {
        passwordInput.value = "";
      }
    }

    function clearFeedbackClasses() {
      feedback.classList.remove("is-valid", "is-invalid", "is-warning");
    }

    function setCheckingState() {
      clearFeedbackClasses();
      feedback.textContent = "Checking if this email is already registered...";
    }

    function setInvalidFormatState() {
      accountExists = false;
      promptedForEmail = "";
      if (submitButton) {
        submitButton.disabled = false;
      }

      clearFeedbackClasses();
      feedback.textContent = "Please enter a valid email address like name@example.com.";
      feedback.classList.add("is-invalid");
      setPasswordState(false);
    }

    function setValidFormatState() {
      clearFeedbackClasses();
      feedback.textContent = "Looks good.";
      feedback.classList.add("is-valid");
      setPasswordState(true);
    }

    function setEmptyState() {
      accountExists = false;
      promptedForEmail = "";
      if (submitButton) {
        submitButton.disabled = false;
      }

      clearFeedbackClasses();
      feedback.textContent = "";
      setPasswordState(false);
    }

    function redirectToSignIn(email) {
      window.location.href = "login.jsp?email=" + encodeURIComponent(email) + "&msg=exists";
    }

    function promptSignIn(email) {
      var proceed = window.confirm("Email already registered. Do you want to sign in now?");
      if (proceed) {
        redirectToSignIn(email);
      }
    }

    function setAccountState(exists, email, shouldPrompt) {
      accountExists = exists;
      if (submitButton) {
        submitButton.disabled = exists;
      }

      if (exists) {
        clearFeedbackClasses();
        feedback.textContent = "Email already registered. ";
        feedback.classList.add("is-warning");
        setPasswordState(false);

        var actionLink = document.createElement("a");
        actionLink.href = "login.jsp?email=" + encodeURIComponent(email) + "&msg=exists";
        actionLink.textContent = "Click here to sign in.";
        actionLink.addEventListener("click", function (event) {
          event.preventDefault();
          redirectToSignIn(email);
        });
        feedback.appendChild(actionLink);

        if (shouldPrompt && promptedForEmail !== email) {
          promptedForEmail = email;
          promptSignIn(email);
        }
      }

      if (!exists) {
        promptedForEmail = "";
        setValidFormatState();
      }
    }

    function checkEmailAvailability(value, shouldPrompt) {
      if (!EMAIL_PATTERN.test(value)) {
        return Promise.resolve(false);
      }

      if (value === lastCheckedEmail && accountExists) {
        setAccountState(true, value, shouldPrompt);
        return Promise.resolve(true);
      }

      if (activeController) {
        activeController.abort();
      }

      activeController = new AbortController();
      accountCheckInFlight = true;
      if (submitButton) {
        submitButton.disabled = true;
      }
      setCheckingState();

      return fetch(getEmailCheckUrl(value), {
        headers: {
          Accept: "application/json"
        },
        credentials: "same-origin",
        signal: activeController.signal
      })
        .then(function (response) {
          if (!response.ok) {
            throw new Error("Unable to verify email availability.");
          }
          return response.json();
        })
        .then(function (data) {
          if (emailInput.value.trim() !== value) {
            return false;
          }

          lastCheckedEmail = value;
          var exists = Boolean(data && data.exists);
          setAccountState(exists, value, shouldPrompt);
          if (!exists && submitButton) {
            submitButton.disabled = false;
          }
          return exists;
        })
        .catch(function (error) {
          if (error && error.name === "AbortError") {
            return false;
          }

          if (emailInput.value.trim() === value) {
            accountExists = false;
            if (submitButton) {
              submitButton.disabled = false;
            }
            clearFeedbackClasses();
            feedback.textContent = "Unable to check email right now. You can still continue.";
            feedback.classList.add("is-warning");
            setPasswordState(true);
          }
          return false;
        })
        .finally(function () {
          accountCheckInFlight = false;
          activeController = null;
        });
    }

    var debouncedCheck = debounce(function () {
      var value = emailInput.value.trim();
      if (!value) {
        setEmptyState();
        return;
      }

      if (!EMAIL_PATTERN.test(value)) {
        setInvalidFormatState();
        return;
      }

      checkEmailAvailability(value, true);
    }, 250);

    emailInput.addEventListener("input", function () {
      var value = emailInput.value.trim();

      if (!value) {
        setEmptyState();
        return;
      }

      if (!EMAIL_PATTERN.test(value)) {
        setInvalidFormatState();
        lastCheckedEmail = "";
        return;
      }

      setValidFormatState();
      debouncedCheck();
    });

    emailInput.addEventListener("blur", function () {
      var value = emailInput.value.trim();
      if (!EMAIL_PATTERN.test(value)) {
        return;
      }
      checkEmailAvailability(value, true);
    });

    form.addEventListener("submit", function (event) {
      event.preventDefault();
      var value = emailInput.value.trim();

      if (!EMAIL_PATTERN.test(value)) {
        setInvalidFormatState();
        return;
      }

      if (accountCheckInFlight) {
        return;
      }

      checkEmailAvailability(value, true).then(function (exists) {
        if (!exists) {
          form.submit();
        }
      });
    });

    setEmptyState();
  }

  function initLoginEmailPrefill() {
    var emailInput = document.querySelector("[data-login-email]");
    if (!emailInput) {
      return;
    }

    var params = new URLSearchParams(window.location.search);
    var email = params.get("email");
    if (!email) {
      return;
    }

    emailInput.value = email;
    emailInput.dispatchEvent(new Event("input", { bubbles: true }));
  }

  function initLoginEmailAvailability() {
    var emailInput = document.querySelector("[data-login-email]");
    var feedback = document.querySelector("[data-login-email-feedback]");
    var createAccountUrl = "index.jsp";

    if (!emailInput || !feedback) {
      return;
    }

    var activeController = null;

    function clearFeedback() {
      feedback.classList.remove("is-valid", "is-invalid", "is-warning");
    }

    function renderAccountMissingMessage(email) {
      clearFeedback();
      feedback.textContent = "No account found for this email. ";
      feedback.classList.add("is-warning");

      var link = document.createElement("a");
      link.href = createAccountUrl + "?email=" + encodeURIComponent(email);
      link.textContent = "Create one here.";
      feedback.appendChild(link);
    }

    function checkLoginEmail() {
      var value = emailInput.value.trim();
      if (!value || !EMAIL_PATTERN.test(value)) {
        return;
      }

      if (activeController) {
        activeController.abort();
      }

      activeController = new AbortController();
      fetch(getEmailCheckUrl(value), {
        headers: {
          Accept: "application/json"
        },
        credentials: "same-origin",
        signal: activeController.signal
      })
        .then(function (response) {
          if (!response.ok) {
            throw new Error("Unable to verify email availability.");
          }
          return response.json();
        })
        .then(function (data) {
          if (emailInput.value.trim() !== value) {
            return;
          }

          if (data && data.exists) {
            clearFeedback();
            feedback.textContent = "Account found. Continue with your password.";
            feedback.classList.add("is-valid");
          } else {
            renderAccountMissingMessage(value);
          }
        })
        .catch(function (error) {
          if (error && error.name === "AbortError") {
            return;
          }
        })
        .finally(function () {
          activeController = null;
        });
    }

    emailInput.addEventListener("input", debounce(checkLoginEmail, 250));
    emailInput.addEventListener("blur", checkLoginEmail);
  }

  function initDismissLoginExistsAlert() {
    var alert = document.querySelector("[data-login-exists-alert]");
    var passwordInput = document.querySelector("[data-login-password]");
    var params = new URLSearchParams(window.location.search);

    if (!alert && params.get("msg") === "exists") {
      var alerts = document.querySelectorAll(".alert.alert-err");
      alerts.forEach(function (item) {
        if (!alert && /already exists with this email/i.test(item.textContent || "")) {
          alert = item;
        }
      });
    }

    if (!alert || !passwordInput) {
      return;
    }

    function dismissExistsAlert() {
      alert.style.display = "none";
    }

    passwordInput.addEventListener("focus", dismissExistsAlert);
    passwordInput.addEventListener("keydown", dismissExistsAlert);
    passwordInput.addEventListener("input", dismissExistsAlert);
  }

  document.addEventListener("DOMContentLoaded", initTheme);
  document.addEventListener("DOMContentLoaded", function () {
    initLiveEmailValidation(
      "[data-login-email]",
      "[data-login-email-feedback]",
      "[data-login-password]",
      "Looks good.",
      "Please enter a valid email address like name@example.com."
    );

    initRegisterEmailAvailability();
    initLoginEmailAvailability();
    initLoginEmailPrefill();
    initDismissLoginExistsAlert();
  });
})();
