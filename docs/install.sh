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

# Pre-create Certs directory and placeholder files to prevent Docker from creating them as directories
# This is a common issue on macOS and ARM machines when Docker mounts non-existent file paths
CERTS_DIR="$VEGA_DIR/Certs"
mkdir -p "$CERTS_DIR"
chmod 700 "$CERTS_DIR"

# Clean up any incorrectly created directories from previous Docker runs
if [ -d "$CERTS_DIR/fullchain.pem" ]; then
    echo "[INFO] Removing incorrectly created directory: $CERTS_DIR/fullchain.pem"
    rm -rf "$CERTS_DIR/fullchain.pem" 2>/dev/null || sudo rm -rf "$CERTS_DIR/fullchain.pem"
fi
if [ -d "$CERTS_DIR/privkey.pem" ]; then
    echo "[INFO] Removing incorrectly created directory: $CERTS_DIR/privkey.pem"
    rm -rf "$CERTS_DIR/privkey.pem" 2>/dev/null || sudo rm -rf "$CERTS_DIR/privkey.pem"
fi

# Create empty placeholder files if they don't exist (will be replaced by init.sh with real certs)
if [ ! -f "$CERTS_DIR/fullchain.pem" ]; then
    install -m 600 /dev/null "$CERTS_DIR/fullchain.pem"
    echo "[INFO] Created placeholder $CERTS_DIR/fullchain.pem"
fi
if [ ! -f "$CERTS_DIR/privkey.pem" ]; then
    install -m 600 /dev/null "$CERTS_DIR/privkey.pem"
    echo "[INFO] Created placeholder $CERTS_DIR/privkey.pem"
fi
echo "[INFO] Certs directory prepared at $CERTS_DIR"

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
    profile_modified_for_bash_zsh=false
    for PROFILE in "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$PROFILE" ]; then
            if ! grep -q "start-vega()" "$PROFILE"; then
                cat <<'EOF' >> "$PROFILE"
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
    start-vega() {
        local orig="$PWD"
        cd "$HOME/.vega" && devbox shell
        cd "$orig"
    }
fi
EOF
                echo "[INFO] Function 'start-vega' added to $PROFILE."
                . "$PROFILE"
                profile_modified_for_bash_zsh=true
            else
                echo "[INFO] Function 'start-vega' already exists in $PROFILE."
            fi
        fi
    done

    if [ "$profile_modified_for_bash_zsh" = true ]; then
        echo "[INFO] To use 'start-vega' in your current terminal, please source your shell profile (e.g., 'source ~/.bashrc') or open a new terminal."
    fi
fi

echo "[SUCCESS] Setup complete! Files are in $VEGA_DIR."
