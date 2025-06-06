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
                # Use a more reliable method to remove the function block
                # Create a temporary file to store the cleaned content
                TEMP_FILE="${PROFILE_FILE}.tmp"
                
                # Read the file line by line and skip the start-vega function block
                awk '/start-vega\(\) {/ { in_start_vega = 1; next }
                    in_start_vega && /^[[:space:]]*}/ { in_start_vega = 0; next }
                    !in_start_vega { print }' "$PROFILE_FILE" > "$TEMP_FILE"
                
                # Replace the original file with the cleaned version
                if mv "$TEMP_FILE" "$PROFILE_FILE"; then
                    info "'start-vega' function removed from $PROFILE_FILE."
                    info "A backup was created: ${PROFILE_FILE}.bak"
                    info "Please source your $PROFILE_FILE or restart your shell for changes to take effect."
                else
                    warn "Failed to update $PROFILE_FILE. Please check permissions and try again."
                fi
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
