#!/usr/bin/env bash
set -e

REPO_USER="ArchetypicalSoftware"
REPO_NAME="VDK-Template"
BRANCH="main"
RAW_URL_BASE="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH"

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
if curl -fsSL "$RAW_URL_BASE/devbox.json" -o devbox.json; then
    echo "[INFO] devbox.json downloaded."
else
    err "Failed to download devbox.json."; exit 1
fi

# Download init.sh
if curl -fsSL "$RAW_URL_BASE/init.sh" -o init.sh; then
    echo "[INFO] init.sh downloaded."
else
    err "Failed to download init.sh."; exit 1
fi

echo "[SUCCESS] Setup complete!"
