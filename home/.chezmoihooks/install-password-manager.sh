#!/bin/bash

#==============================================================================
#description  :chezmoi hook (hooks.read-source-state.pre) script.
#              This hook running after chezmoi init has cloned dotfile repo but
#              before chezmoi has read the source state.
#              The script ensure that a password-manager-binary is installed
#              before chezmoi use it to applies template that may depend on it.
#              chezmoi executes this hook every time any command reads the source
#              state so the hook should terminate as quickly as possible if there
#              is no work to do.
#version      :0.3
#date         :2025-10-25
#==============================================================================

# Source utility functions
# source "../.scripts/utils.sh"

set -e # -e: script exit on error

## Variables:
PASSWORD_MANAGER_NAME="Bitwarden CLI"
BITWARDEN_BINARY_NAME="bw"
BITWARDEN_BINARY_URL="https://github.com/bitwarden/clients/releases/download/cli-v2025.10.0/bw-linux-2025.10.0.zip"
INSTALL_DIR="/bin"
TEMP_DIR="/tmp/bitwarden_install"
BITWARDEN_BINARY_PATH="$INSTALL_DIR/$BITWARDEN_BINARY_NAME"

## Log (enhanced with colors and symbols):
header() {
  echo -e "\n\033[1;35m⮞ $*\033[0m"
  echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

info() { echo -e "\033[1;36m  ℹ️  $* \033[0m"; }

success() { echo -e "\033[1;32m  ✅  $* \033[0m"; }

warning() { echo -e "\033[1;33m  ⚠️  WARNING: $* \033[0m"; }

error() { echo -e "\033[1;31m  ❌  ERROR: $* \033[0m" >&2; }

step() { echo -e "\n\033[1;34m  ➜  $* \033[0m"; }


# exit immediately if password-manager-binary is already in $PATH
type $INSTALL_DIR/bw >/dev/null 2>&1 && exit

## Main
header "chezmoi: Private mode selected \n \
  $PASSWORD_MANAGER_NAME password mannager installation & configuration"

case "$(uname -s)" in
Linux)
    step "Starting $PASSWORD_MANAGER_NAME installation..."
    # Download password manager binary
    # step "Downloading $PASSWORD_MANAGER_NAME binary package from:\n $BITWARDEN_BINARY_URL"
    mkdir -p "$TEMP_DIR"
    if ! command wget -q -O "$TEMP_DIR/$BITWARDEN_BINARY_NAME.zip" "$BITWARDEN_BINARY_URL" ; then
      error "Failed to download package from: $BITWARDEN_BINARY_URL"
      exit 1
    fi
    success "Package downloaded successfully from: \
    $BITWARDEN_BINARY_URL"

    # Unzip password manager binary
    # step "Unzip password manager binary package..."
    # Validation: Check unzip availability
    if !  unzip -v > /dev/null 2>&1; then
      warning "unzip not installed"
      info "Installing unzip package..."
      if ! sudo apt install -qq -y unzip > /dev/null 2>&1 ; then
        error "Failed to install unzip via apt-get"
        exit 1
      fi
      success "unzip installed successfully"
    fi
    if ! sudo unzip -qq -d "$INSTALL_DIR" "$TEMP_DIR/$BITWARDEN_BINARY_NAME.zip" ; then
      error "Failed to unzip binary package"
      exit 1
    fi
    success "Package unzipped successfully"

    # Set executable permissions
    # step "Setting executable permissions on password manager binary..."
    if ! sudo chmod +x "$BITWARDEN_BINARY_PATH" ; then
      error "Failed to set executable permissions"
      exit 1
    fi
    success "Executable permissions set successfully"

    # Cleanup temporary files
    # step "Cleaning up temporary files..."
    if ! rm -rf "$TEMP_DIR" ; then
      warning "Failed to remove temporary files"
    else
      success "Temporary files removed successfully"
    fi

    # Configure password manager URL server 
    step "Configuring $PASSWORD_MANAGER_NAME server URL..."    
    URL=$(whiptail \
      --title "$PASSWORD_MANAGER_NAME configuration" \
      --inputbox "Enter the server URL: \n(default: https://vault.bitwarden.eu)" \
      10 50 3>&1 1>&2 2>&3 \
      "https://")
    
    if [ -z "$URL" ]; then
      URL="https://vault.bitwarden.eu"
    else
      URL=$(echo "$URL" | xargs) # trim whitespace 
      # Valid URL format
      if ! echo "$URL" | grep -E -q '^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$' ; then
        warning "Invalid URL format. Using default URL."
        URL="https://vault.bitwarden.eu"
      fi
    fi
    info "Using server URL: $URL"
    if ! "$BITWARDEN_BINARY_PATH" config server "$URL" 1> /dev/null ; then
      error "Failed to set server URL"
      exit 1
    fi
    success "Server URL set successfully"

    # Login to password manager account
    step "Login to your $PASSWORD_MANAGER_NAME account"
    if ! SESSION_KEY=$("$BITWARDEN_BINARY_PATH" login) ; then
      error "Failed to login to Bitwarden"
      exit 1
    fi
    success "Logged in to Bitwarden successfully"

    SESSION_KEY=$(echo "$SESSION_KEY" | \
                  awk -F' BW_SESSION="' '{print $2}' | \
                  awk -F'"' '{print $1}' | \
                  xargs) # trim whitespace
    info "BW_SESSION session key: $SESSION_KEY"
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
