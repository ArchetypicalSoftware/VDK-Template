# /bin/bash
# Docker permissions hardening for Linux and macOS
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ "$OS_TYPE" = "linux" ]; then
    if ! getent group docker > /dev/null 2>&1; then
        echo "[INFO] Creating 'docker' group (requires sudo)"
        sudo groupadd docker
    fi
    if ! groups $USER | grep -q '\bdocker\b'; then
        echo "[INFO] Adding user $USER to 'docker' group (requires sudo)"
        sudo usermod -aG docker "$USER"
        echo "[INFO] Please exit and restart your shell to pick up group membership changes."
        exit 0
    fi
    if ! command -v docker >/dev/null 2>&1; then
        echo "[ERROR] Docker CLI is not installed. Please install Docker before proceeding."
        exit 1
    fi
    echo "[SUCCESS] Docker permissions are set up for $USER."
elif [ "$OS_TYPE" = "darwin" ]; then
    if ! command -v docker >/dev/null 2>&1; then
        echo "[ERROR] Docker CLI is not installed. Please install Docker Desktop for Mac."
        exit 1
    fi
    # Check if Docker Desktop is running
    if ! docker info >/dev/null 2>&1; then
        echo "[ERROR] Docker Desktop does not appear to be running. Please start Docker Desktop."
        exit 1
    fi
    echo "[SUCCESS] Docker is available on macOS."
else
    echo "[ERROR] Unsupported OS: $OS_TYPE. This script supports only Linux and macOS."
    exit 1
fi

echo "Welcome to Vega VDK"
# Variables
REPO="ArchetypicalSoftware/VDK" # Replace with your GitHub repository (e.g., username/repo)
DOWNLOAD_DIR="$HOME/.vega/.bin" # Specify the download directory

    # Detect OS and architecture and map to .NET Runtime Identifiers (RIDs)
    UNAME_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    UNAME_ARCH=$(uname -m)
    case "$UNAME_OS" in
        linux)
            RID_OS="linux" ;;
        darwin)
            RID_OS="osx" ;;
        *)
            echo "Unsupported OS: $UNAME_OS"
            exit 1 ;;
    esac

    case "$UNAME_ARCH" in
        x86_64|amd64)
            RID_ARCH="x64" ;;
        arm64|aarch64)
            RID_ARCH="arm64" ;;
        *)
            echo "Unsupported architecture: $UNAME_ARCH"
            exit 1 ;;
    esac

    RID="$RID_OS-$RID_ARCH"
    ASSET_NAME="vega-$RID.tar.gz"

    # Get the latest release information
    echo "Fetching the latest release information..."
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
    VERSION=$(echo "$LATEST_RELEASE" | jq -r ".tag_name")
    CURRENT=$(cat $HOME/.vega/.bin/vdk.version)
    if [ "$VERSION" != "$CURRENT" ]; then
        # Extract the browser_download_url for the detected asset
        ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name == \"$ASSET_NAME\") | .browser_download_url")

        if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" == "null" ]; then
            echo "Error: Asset for OS '$OS' and arch '$ARCH' (expected name: $ASSET_NAME) not found in the latest release."
            exit 1
        fi

        # Create the download directory if it doesn't exist
        mkdir -p "$DOWNLOAD_DIR"

        # Download the asset directly (no token needed)
        echo "Downloading asset \"$ASSET_NAME\"..."
        curl -L "$ASSET_URL" -o "$DOWNLOAD_DIR/$ASSET_NAME"

        echo "Download complete! File saved to \"$DOWNLOAD_DIR/$ASSET_NAME\""  
        echo "Extracting Vega CLI..."
        tar --overwrite -xvf "$DOWNLOAD_DIR/$ASSET_NAME" -C "$DOWNLOAD_DIR"
        # Find the vega binary in the extracted files and move it to $HOME/.vega/.bin/vega
        FOUND_VEGA=$(find "$DOWNLOAD_DIR" -type f -name vega | head -n 1)
        if [ -n "$FOUND_VEGA" ]; then
            if [ "$FOUND_VEGA" != "$HOME/.vega/.bin/vega" ]; then
                mv -f "$FOUND_VEGA" $HOME/.vega/.bin/vega
                echo "[INFO] Vega binary moved to $HOME/.vega/.bin/vega"
            else
                echo "[INFO] Vega binary already in $HOME/.vega/.bin/vega"
            fi
        else
            echo "[WARNING] Vega binary not found after extraction."
        fi
        rm "$DOWNLOAD_DIR/$ASSET_NAME"
        echo "$VERSION" > "$DOWNLOAD_DIR/vdk.version"
        echo "Version: $VERSION" 
    else
        echo "Version: $CURRENT"
    fi
    cd $HOME/.vega/.bin
    BIN_PATH=$(pwd)
    cd ..
    echo "$PATH" | grep -q $BIN_PATH
    if [ $? -ne 0 ]; then
        echo "[INFO] Adding $BIN_PATH to PATH for this session."
        export PATH="$PATH:$BIN_PATH"
    fi

    # Check Vega CLI version
    if command -v vega >/dev/null 2>&1; then
        echo "[INFO] Vega CLI version output:"
        VEGA_OUT="$(vega --version 2>&1)"
        VEGA_EXIT=$?
        echo "$VEGA_OUT"
        if [ "$OS_TYPE" = "darwin" ]; then
            # 1. Check for architecture mismatch
            MAC_ARCH=$(uname -m)
            BIN_ARCH=$(file .bin/vega | grep -oE 'arm64|x86_64')
            if [ "$MAC_ARCH" = "arm64" ] && [ "$BIN_ARCH" = "x86_64" ]; then
                echo "[WARNING] You are running an x64 binary on Apple Silicon. Try installing Rosetta: sudo softwareupdate --install-rosetta, or use the osx-arm64 build."
            elif [ "$MAC_ARCH" = "x86_64" ] && [ "$BIN_ARCH" = "arm64" ]; then
                echo "[ERROR] You are running an ARM64 binary on an Intel Mac. Use the osx-x64 build."
            fi

            # 2. Check for missing Swift runtime libraries
            MISSING_SWIFT=0
            for LIB in libswiftCore.dylib libswiftFoundation.dylib; do
                if ! otool -L .bin/vega | grep -q "$LIB"; then
                    MISSING_SWIFT=1
                fi
            done
            if [ $MISSING_SWIFT -eq 1 ]; then
                echo "[WARNING] Vega CLI may require the Swift runtime. Install Xcode or Xcode Command Line Tools: xcode-select --install"
            fi

            # 3. If killed or nonzero exit, print suggestions
            if echo "$VEGA_OUT" | grep -qi 'killed' || [ $VEGA_EXIT -ne 0 ]; then
                echo "[ERROR] Vega CLI failed to run. Suggestions:"
                echo "- Ensure you are using the correct binary for your architecture."
                echo "- Try installing Rosetta (for x64 on Apple Silicon): sudo softwareupdate --install-rosetta"
                echo "- Install Xcode or Xcode Command Line Tools for Swift runtime."
                echo "- Check for missing libraries: otool -L .bin/vega"
                echo "- For more details, check system logs: log show --predicate 'process == \"vega\"' --info --last 1h"
            fi
        fi
    else
        echo "[WARNING] Vega CLI not found in PATH or not executable."
    fi
