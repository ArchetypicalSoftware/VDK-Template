#!/usr/bin/env bash

# Determine user profile directory (cross-platform)
if [ "$OS" = "Windows_NT" ]; then
    USER_PROFILE="$USERPROFILE"
    POWERSHELL_PROFILE="$USERPROFILE/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
else
    USER_PROFILE="$HOME"
fi
VEGA_DIR="$USER_PROFILE/.vega"

# Helper for output
info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

info "Starting uninstallation process for VDK-Template components..."

# Remove 'start-vega' alias/function
info "Attempting to remove 'start-vega' alias/function..."

if [ "$OS" = "Windows_NT" ]; then
    if [ -f "$POWERSHELL_PROFILE" ]; then
        if grep -q "function start-vega" "$POWERSHELL_PROFILE"; then
            # Using a temporary file to remove the function block
            # This is safer than in-place sed for PowerShell profiles
            TEMP_PROFILE="$(mktemp)"
            awk '
            /function start-vega/ { in_func=1; next }
            /Pop-Location }/ && in_func { in_func=0; next }
            !in_func { print }
            ' "$POWERSHELL_PROFILE" > "$TEMP_PROFILE" && mv "$TEMP_PROFILE" "$POWERSHELL_PROFILE"
            info "'start-vega' function removed from PowerShell profile: $POWERSHELL_PROFILE"
            info "You may need to restart PowerShell for changes to take effect."
        else
            info "'start-vega' function not found in PowerShell profile: $POWERSHELL_PROFILE"
        fi
    else
        info "PowerShell profile not found: $POWERSHELL_PROFILE"
    fi
else
    # Bash and Zsh
    for PROFILE_FILE in "$USER_PROFILE/.bash_profile" "$USER_PROFILE/.bashrc" "$USER_PROFILE/.zshrc"; do
        if [ -f "$PROFILE_FILE" ]; then
            if grep -q "start-vega()" "$PROFILE_FILE"; then
                # Use sed to remove the function. This is a bit complex due to multiline.
                # We'll remove from 'if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then' to the matching 'fi'
                # that contains the start-vega function.
                # This assumes the structure from the install script.
                sed -i.bak "/if \[ -n \"\$BASH_VERSION\" \] || \[ -n \"\$ZSH_VERSION\" \]; then/,/    }\nfi/ { /start-vega()/ { d; }; }" "$PROFILE_FILE"
                # A simpler sed to remove the specific start-vega function block if the above is too broad
                # sed -i.bak '/start-vega() {/,/}/d' "$PROFILE_FILE"
                # For a more robust removal, we'll target the specific block more carefully:
                awk '
                BEGIN { printing=1 }
                /start-vega\(\) {/ { printing=0; next }
                /cd "\$orig"\n    }/ { printing=1; next }
                printing { print }
                ' "$PROFILE_FILE" > "${PROFILE_FILE}.tmp" && mv "${PROFILE_FILE}.tmp" "$PROFILE_FILE"

                info "'start-vega' function removed from $PROFILE_FILE. A backup was created: ${PROFILE_FILE}.bak"
                info "Please source your $PROFILE_FILE or restart your shell for changes to take effect."
            else
                info "'start-vega' function not found in $PROFILE_FILE."
            fi
        else
            info "Profile file not found: $PROFILE_FILE"
        fi
    done
fi

# Remove downloaded files and directory
if [ -d "$VEGA_DIR" ]; then
    info "Removing directory $VEGA_DIR and its contents..."
    if rm -rf "$VEGA_DIR"; then
        info "Directory $VEGA_DIR removed successfully."
    else
        warn "Failed to remove directory $VEGA_DIR. Please remove it manually."
    fi
else
    info "Directory $VEGA_DIR not found."
fi

warn "---------------------------------------------------------------------"
warn "MANUAL ACTION REQUIRED FOR DEVBOX UNINSTALLATION:"
warn "The installation script may have installed 'devbox'."
warn "This uninstallation script does NOT automatically remove 'devbox'"
warn "as it might be used by other applications."
warn "If you wish to uninstall devbox, please follow the instructions"
warn "on the Jetify documentation or look for an uninstall script provided by devbox."
warn "Typically, you might look for '~/.local/share/devbox' or similar directories."
warn "---------------------------------------------------------------------"

info "Uninstallation process complete."
