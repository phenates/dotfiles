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
source "$HOME/.local/share/chezmoi/home/.utils/utils.sh"

set -euo pipefail # Strict error handling

# Security settings
umask 077 # Set strict permissions for new files

## Variables:
# PASSWORD_MANAGER_NAME="Bitwarden CLI"
BIT_BIN_CMD="bw"
BIT_BIN_URL="https://github.com/bitwarden/clients/releases/download/cli-v2025.10.0/bw-linux-2025.10.0.zip"
BIT_BIN_SHA256="0544c64d3e9932bb5f2a70e819695ea78186a44ac87a0b1d753e9c55217041d9"  # À remplacer par le vrai SHA256
INSTALL_DIR="/usr/local/bin"
TEMP_DIR=$(mktemp -d -t bwinstall.XXXX)
BIT_BIN_PATH="$INSTALL_DIR/$BIT_BIN_CMD"

## Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

## Main
header "chezmoi -> Private mode enabled \n \
  Bitwarden CLI installation & configuration"

case "$(uname -s)" in
  Linux)
      ## Check requiered package
      step "Tools validation..."
      if ! require_tools wget unzip; then
        exit 1
      fi
      success "Requiered tools available"
      
      # Download Bitwarden binary and verify checksum
      step "Bitwarden CLI installation..."
      # Download Bitwarden binary
      mkdir -p "$TEMP_DIR"
      if ! wget -q -O "$TEMP_DIR/$BIT_BIN_CMD.zip" "$BIT_BIN_URL" ; then
        error "Failed to download package from: \n $BIT_BIN_URL"
        exit 1
      fi
      
      # Verify SHA256 checksum
      DOWNLOADED_SHA256=$(sha256sum "$TEMP_DIR/$BIT_BIN_CMD.zip" | cut -d' ' -f1)
      if [ "$DOWNLOADED_SHA256" != "$BIT_BIN_SHA256" ]; then
        error "Checksum verification failed!"
        error "Expected: $BIT_BIN_SHA256"
        error "Got: $DOWNLOADED_SHA256"
        exit 1
      fi
      success "Binary file downloaded and verified successfully from:_n \
      $BIT_BIN_URL"

      ## Unzip password manager binary
      if ! sudo unzip -qq -d "$INSTALL_DIR" "$TEMP_DIR/$BIT_BIN_CMD.zip" ; then
        error "Failed to unzip binary package to: $INSTALL_DIR"
        exit 1
      fi
      success "Package unzipped successfully to: $INSTALL_DIR"

      # Set secure permissions (only root and owner can access)
      if ! sudo chown root:root "$BIT_BIN_PATH" || \
         ! sudo chmod 755 "$BIT_BIN_PATH"; then
        error "Failed to set secure permissions"
        exit 1
      fi
      success "Secure permissions set successfully"

      # Verify permissions
      if ! [ -x "$BIT_BIN_PATH" ]; then
        error "Binary is not executable"
        exit 1
      fi
      
      # Verify ownership
      if [ "$(stat -c '%U:%G' "$BIT_BIN_PATH")" != "root:root" ]; then
        error "Binary has incorrect ownership"
        exit 1
      fi

      ## Cleanup temporary files
      step "Cleaning up temporary files..."
      if ! rm -rf "$TEMP_DIR" ; then
        warning "Failed to remove temporary files"
      else
        success "Temporary files removed successfully"
      fi

      ## Configure Bitwarden URL server
      step "Configuring Bitwarden server URL..."

      # Prompt with validation loop
      while true; do
        printf "  Enter the Bitwarden server URL (default: https://vault.bitwarden.eu): "
        read -r URL

        # Use default if empty
        if [ -z "$URL" ]; then
          URL="https://vault.bitwarden.eu"
          break
        fi

        # Trim whitespace
        URL=$(echo "$URL" | xargs)

        # Validate URL format (must start with http:// or https://)
        if echo "$URL" | grep -E -q '^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$'; then
          break
        else
          warning "Invalid URL format. Please enter a valid URL (e.g., https://vault.bitwarden.eu)"
        fi
      done

      info "Using server URL: $URL"
      if ! "$BIT_BIN_PATH" config server "$URL" >/dev/null 2>&1 ; then
        error "Failed to set server URL"
        exit 1
      fi
      success "Server URL set successfully to: ~/.config/Bitwarden CLI/data.json"

      ## Login to Bitwarden account
      step "Login to your Bitwarden account"
      info "Please enter your Bitwarden credentials when prompted..."

      # Use bw login --raw which handles credential prompting itself
      # This is more secure as credentials are never stored in shell variables
      if ! "$BIT_BIN_PATH" login --raw; then
        error "Failed to login to Bitwarden"
        exit 1
      fi
      success "Logged into Bitwarden successfully"

      # Clear sensitive variables
      unset URL

      echo ""
      success "Bitwarden CLI installation & configuration completed! 🎉"
      echo ""
      ;;
  *)
      echo "unsupported OS"
      exit 1
      ;;
esac
