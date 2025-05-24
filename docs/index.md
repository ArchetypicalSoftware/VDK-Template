---
title: VDK-Template Quick Install
---

# VDK-Template: Quick Start

## 🚀 One-Line Installation

Copy and paste this command into your terminal, or click the button to copy:

<div style="position: relative; margin-bottom: 1em;">
  <pre style="background: #222; color: #fff; padding: 1em; border-radius: 6px; overflow-x: auto;">
    <code id="install-cmd">bash -c "$(curl -fsSL https://vdk.sh/install.sh)"</code>
  </pre>
  <button onclick="copyInstallCmd()" id="copy-btn" style="position: absolute; top: 10px; right: 10px; background: #00b894; color: white; border: none; border-radius: 4px; padding: 0.5em 1em; cursor: pointer; font-weight: bold; display: inline-flex; align-items: center; gap: 0.5em;">
  <img src="vega.png" id="vega-logo" alt="Vega Logo" /> Copy
</button>
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

- This will:
  1. Check for [devbox](https://www.jetify.com/devbox); install if missing.
  2. Download the latest `devbox.json` and `init.sh` from this repo.
  3. Print helpful status and error messages.

---

## Manual Setup (Advanced)

1. Clone the repository:
   ```bash
   git clone https://github.com/ArchetypicalSoftware/VDK-Template.git
   cd VDK-Template
   ```
2. Run `devbox shell` to initialize the environment.

---

## About
- See the [README](https://github.com/ArchetypicalSoftware/VDK-Template#readme) for full documentation.
