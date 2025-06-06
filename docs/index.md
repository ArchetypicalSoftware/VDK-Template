---
title: VDK Quick Install
---

# VDK Quick Install

## 🚀 One-Line Installation

Copy and paste this command into your terminal, or click the button to copy:

<div style="position: relative; margin-bottom: 1em; text-align: center;">
  <img src="vega.png" id="vega-logo" alt="Vega Logo" style="height: 48px; margin-bottom: 0.5em; display: block; margin-left: auto; margin-right: auto;" />
  <pre style="background: #222; color: #fff; padding: 1em; border-radius: 6px; overflow-x: auto; margin: 0 auto 0.5em auto; max-width: 700px;">
    <code id="install-cmd">bash -c "$(curl -fsSL https://vdk.sh/install.sh)"</code>
  </pre>
</div>

**After installation, run:**

```bash
start-vega
```

This will launch your Vega development environment with all tools and CLI available.

  <button onclick="copyInstallCmd()" id="copy-btn" style="position: absolute; top: 10px; right: 10px; background: #00b894; color: white; border: none; border-radius: 4px; padding: 0.5em 1em; cursor: pointer; font-weight: bold;">Copy</button>
</div>
<div id="copy-msg" style="color: #00b894; font-weight: bold; display: none; margin-bottom: 1em;">Copied!</div>

<script>
function copyInstallCmd() {
  var text = document.getElementById('install-cmd').innerText;
  navigator.clipboard.writeText(text).then(function() {
    var msg = document.getElementById('copy-msg');
    msg.style.display = 'block';
    setTimeout(function() { msg.style.display = 'none'; }, 1200);
  });
}
</script>

<script>
// Inject company logo into mkdocs header
window.addEventListener('DOMContentLoaded', function() {
  var header = document.querySelector('.wy-header .site-name');
  if (header && !document.querySelector('.arche-logo')) {
    var logo = document.createElement('img');
    logo.src = 'logo.png';
    logo.alt = 'Archetypical Logo';
    logo.className = 'arche-logo';
    header.parentNode.insertBefore(logo, header);
  }
});
</script>

- This will:
  1. Check for [devbox](https://www.jetify.com/devbox); install if missing.
  2. Download the latest `devbox.json` and `init.sh` from this repo.
  3. Print helpful status and error messages.

## 🔄 Uninstallation

To uninstall VDK, run the following command:

```bash
bash -c "$(curl -fsSL https://vdk.sh/uninstall.sh)"
```

This will:
1. Remove the VDK installation and related files
2. Clean up any configuration files
3. Restore your system to its pre-installation state

After uninstallation, you can verify that VDK has been removed by checking that the `start-vega` command is no longer available.

---

## About
- See the [README](https://github.com/ArchetypicalSoftware/VDK-Template#readme) for full documentation.
