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

# exit immediately if password-manager-binary is already in $PATH
command -v bw >/dev/null 2>&1 && exit

# Source utility functions
source "$HOME/.local/share/chezmoi/home/.scripts/utils.sh"

set -e # -e: script exit on error

## Variables:
# PASSWORD_MANAGER_NAME="Bitwarden CLI"
BIT_BIN_CMD="bw"
BIT_BIN_URL="https://github.com/bitwarden/clients/releases/download/cli-v2025.10.0/bw-linux-2025.10.0.zip"
INSTALL_DIR="$HOME/.local/bin"
TEMP_DIR=$(mktemp -d)
BIT_BIN_PATH="$INSTALL_DIR/$BIT_BIN_CMD"

## Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

## Main
header "chezmoi: Private mode enabled \n \
  Bitwarden CLI installation & configuration"

case "$(uname -s)" in
  Linux)
      step "Bitwarden CLI installation..."
      
      # Check requiered package
      if ! require_tools wget unzip whiptail; then
        exit 1
      fi
      success "Requiered tools available"
      
      # Download Bitwarden binary
      mkdir -p "$TEMP_DIR"
      if ! command wget -q -O "$TEMP_DIR/$BIT_BIN_CMD.zip" "$BIT_BIN_URL" ; then
        error "Failed to download package from: $BIT_BIN_URL"
        exit 1
      fi
      success "Binary file downloaded successfully from: \
      $BIT_BIN_URL"

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
      if ! sudo unzip -qq -d "$INSTALL_DIR" "$TEMP_DIR/$BIT_BIN_CMD.zip" ; then
        error "Failed to unzip binary package"
        exit 1
      fi
      success "Package unzipped successfully"

      # Set executable permissions
      # step "Setting executable permissions on password manager binary..."
      if ! sudo chmod +x "$BIT_BIN_PATH" ; then
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

      # Configure Bitwarden URL server 
      step "Configuring Bitwarden CLI server URL..."    
      URL=$(whiptail \
        --title "Bitwarden configuration" \
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
      if ! "$BIT_BIN_PATH" config server "$URL" 1> /dev/null ; then
        error "Failed to set server URL"
        exit 1
      fi
      success "Server URL set successfully"

      # Login to Bitwarden account
      step "Login to your Bitwarden account"

      EMAIL=$(whiptail \
        --title "Bitwarden login" \
        --inputbox "Enter your email address:" \
        10 50 3>&1 1>&2 2>&3 )

      PASS=$(whiptail \
        --title "Bitwarden login" \
        --passwordbox "Enter your master password:" \
        10 50 3>&1 1>&2 2>&3 )

      if ! SESSION_KEY=$("$BIT_BIN_PATH" login --raw "$EMAIL" "$PASS") ; then
        error "Failed to login to Bitwarden"
        exit 1
      fi
      success "Logged in to Bitwarden successfully"
      export BW_SESSION="$SESSION_KEY"

      # SESSION_KEY=$(bw login --raw "$EMAIL" "$PASSWORD") # si justifiable
      # export BW_SESSION="$SESSION_KEY"

      # SESSION_KEY=$(echo "$SESSION_KEY" | \
      #               awk -F' BW_SESSION="' '{print $2}' | \
      #               awk -F'"' '{print $1}' | \
      #               xargs) # trim whitespace
      # info "BW_SESSION session key: $SESSION_KEY"
      ;;
  *)
      echo "unsupported OS"
      exit 1
      ;;
esac
