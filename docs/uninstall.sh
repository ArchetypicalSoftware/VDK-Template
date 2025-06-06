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
                # Use sed to remove the specific block added by install script
                # Create a backup of the original file
                cp "$PROFILE_FILE" "${PROFILE_FILE}.bak"
                
                # Remove the entire block containing start-vega function and its contents
                sed -i.bak '/if \[ -n "\$BASH_VERSION" \] || \[ -n "\$ZSH_VERSION" \]; then/,/fi/ { 
                    /if \[ -n "\$BASH_VERSION" \] || \[ -n "\$ZSH_VERSION" \]; then/ { 
                        d 
                    }
                    /start-vega() {/,/}/ { 
                        d 
                    }
                    /fi/ { 
                        d 
                    }
                }' "$PROFILE_FILE"
                
                # Check if the file still exists and has content
                if [ -s "$PROFILE_FILE" ]; then
                    info "Removed 'start-vega' function and its surrounding conditional block from $PROFILE_FILE."
                    info "A backup was created: ${PROFILE_FILE}.bak"
                    info "Please source your $PROFILE_FILE or restart your shell for changes to take effect."
                else
                    warn "Failed to update $PROFILE_FILE. Please check permissions and try again."
                    # Restore from backup if file is empty
                    cp "${PROFILE_FILE}.bak" "$PROFILE_FILE"
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
