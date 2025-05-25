#!/usr/bin/env bash
set -e

REPO_USER="ArchetypicalSoftware"
REPO_NAME="VDK-Template"
BRANCH="main"
RAW_URL_BASE="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH"

# Determine user profile directory (cross-platform)
if [[ "$OS" == "Windows_NT" ]]; then
    USER_PROFILE="$USERPROFILE"
else
    USER_PROFILE="$HOME"
fi
VEGA_DIR="$USER_PROFILE/.vega"
mkdir -p "$VEGA_DIR"

# Helper for error output
err() { echo "[ERROR] $1" >&2; }

# Check for devbox
if ! command -v devbox >/dev/null 2>&1; then
    echo "[INFO] devbox not found. Installing..."
    if ! curl -fsSL https://get.jetify.com/devbox | bash; then
        err "Failed to install devbox. Aborting."; exit 1
    fi
    echo "[INFO] devbox installed. You may need to restart your shell."
else
    echo "[INFO] devbox is already installed."
fi

# Download devbox.json
if curl -fsSL "$RAW_URL_BASE/devbox.json" -o "$VEGA_DIR/devbox.json"; then
    echo "[INFO] devbox.json downloaded to $VEGA_DIR."
else
    err "Failed to download devbox.json."; exit 1
fi

# Download init.sh
if curl -fsSL "$RAW_URL_BASE/init.sh" -o "$VEGA_DIR/init.sh"; then
    chmod a+x "$VEGA_DIR/init.sh"
    echo "[INFO] init.sh downloaded to $VEGA_DIR and made executable."
else
    err "Failed to download init.sh."; exit 1
fi

# Set up persistent global alias 'start-vega'
echo "[INFO] Setting up global alias 'start-vega'..."

if [[ "$OS" == "Windows_NT" ]]; then
    # PowerShell profile
    POWERSHELL_PROFILE="$USERPROFILE/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
    mkdir -p "$(dirname "$POWERSHELL_PROFILE")"
    if ! grep -q "start-vega" "$POWERSHELL_PROFILE" 2>/dev/null; then
        echo "function start-vega { Push-Location \"$USERPROFILE\\.vega\"; devbox shell; Pop-Location }" >> "$POWERSHELL_PROFILE"
        echo "[INFO] Alias 'start-vega' added to PowerShell profile. Restart PowerShell to use it."
    else
        echo "[INFO] Alias 'start-vega' already exists in PowerShell profile."
    fi
else
    # Bash and Zsh
    for PROFILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$PROFILE" ]; then
            if ! grep -q "alias start-vega" "$PROFILE"; then
                echo 'ssv() { cd "$HOME/.vega" && devbox shell; cd -; }' >> "$PROFILE"
                echo "alias start-vega='source ssv'" >> "$PROFILE"
                echo "[INFO] Alias 'start-vega' added to $PROFILE."
            else
                echo "[INFO] Alias 'start-vega' already exists in $PROFILE."
            fi
        fi
    done
fi

echo "[SUCCESS] Setup complete! Files are in $VEGA_DIR."

