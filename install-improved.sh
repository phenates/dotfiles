#!/usr/bin/env bash

#==============================================================================
#title            :install.sh
#description      :Installs chezmoi binary and initializes dotfiles from GitHub
#                  with comprehensive error handling and security validations
#author           :phenates
#date             :2025-10-31
#version          :0.5.0
#usage            :bash <(curl -fsSL https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)
#requirements     :bash 4.0+, curl or wget
#==============================================================================

# Strict mode with comprehensive error handling
set -Eeuo pipefail

# Bash version check (require 4.0+)
if [ -z "${BASH_VERSION:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  printf "ERROR: This script requires bash 4.0 or higher\n" >&2
  printf "Current version: %s\n" "${BASH_VERSION:-unknown}" >&2
  exit 1
fi

#==============================================================================
# CONFIGURATION
#==============================================================================

readonly GITHUB_USERNAME="phenates"
readonly BIN_DIR="${HOME}/.local/bin"
readonly CHEZMOI_INSTALLER_URL="https://get.chezmoi.io"
readonly INSTALL_TIMEOUT=60

#==============================================================================
# COLOR AND SYMBOL DETECTION
#==============================================================================

# Detect terminal capabilities for colors and emojis
detect_terminal_features() {
  local has_colors=false
  local has_emoji=false

  # Check color support
  if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    local colors
    colors="$(tput colors 2>/dev/null || echo 0)"
    if [ "${colors}" -ge 8 ]; then
      has_colors=true
    fi
  fi

  # Check emoji support (basic heuristic)
  if [ -n "${TERM:-}" ] && [ "${TERM}" != "dumb" ]; then
    has_emoji=true
  fi

  # Set colors
  if [ "${has_colors}" = true ]; then
    readonly COLOR_RESET='\033[0m'
    readonly COLOR_RED='\033[1;31m'
    readonly COLOR_GREEN='\033[1;32m'
    readonly COLOR_YELLOW='\033[1;33m'
    readonly COLOR_BLUE='\033[1;34m'
    readonly COLOR_MAGENTA='\033[1;35m'
    readonly COLOR_CYAN='\033[1;36m'
  else
    readonly COLOR_RESET=''
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_MAGENTA=''
    readonly COLOR_CYAN=''
  fi

  # Set symbols
  if [ "${has_emoji}" = true ]; then
    readonly SYM_ARROW="⮞"
    readonly SYM_CHECK="✅"
    readonly SYM_CROSS="❌"
    readonly SYM_WARN="⚠️"
    readonly SYM_INFO="ℹ️"
    readonly SYM_STEP="➜"
    readonly SYM_PROMPT="❓"
  else
    readonly SYM_ARROW=">>"
    readonly SYM_CHECK="[OK]"
    readonly SYM_CROSS="[ERROR]"
    readonly SYM_WARN="[WARN]"
    readonly SYM_INFO="[INFO]"
    readonly SYM_STEP="->"
    readonly SYM_PROMPT="?"
  fi
}

detect_terminal_features

#==============================================================================
# LOGGING FUNCTIONS
#==============================================================================

header() {
  printf "\n%b%s  %s\n%b" "${COLOR_MAGENTA}" "${SYM_ARROW}" "$*" "${COLOR_RESET}"
  printf "%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n%b" \
    "${COLOR_MAGENTA}" "${COLOR_RESET}"
}

info() {
  printf "%b  %s  %s\n%b" "${COLOR_CYAN}" "${SYM_INFO}" "$*" "${COLOR_RESET}"
}

success() {
  printf "%b  %s  %s\n%b" "${COLOR_GREEN}" "${SYM_CHECK}" "$*" "${COLOR_RESET}"
}

warning() {
  printf "%b  %s  WARNING: %s\n%b" "${COLOR_YELLOW}" "${SYM_WARN}" "$*" "${COLOR_RESET}"
}

error() {
  printf "%b  %s  ERROR: %s\n%b" "${COLOR_RED}" "${SYM_CROSS}" "$*" "${COLOR_RESET}" >&2
}

step() {
  printf "\n%b  %s  %s\n%b" "${COLOR_BLUE}" "${SYM_STEP}" "$*" "${COLOR_RESET}"
}

prompt() {
  printf "\n%b  %s  %s\n%b" "${COLOR_YELLOW}" "${SYM_PROMPT}" "$*" "${COLOR_RESET}"
}

#==============================================================================
# ERROR HANDLING
#==============================================================================

# Trap errors and provide context
error_handler() {
  local line_number="$1"
  local error_code="$2"
  error "Script failed at line ${line_number} with exit code ${error_code}"
  error "Check the error messages above for details"
  exit "${error_code}"
}

trap 'error_handler ${LINENO} $?' ERR

# Cleanup temporary files on exit
cleanup() {
  if [ -n "${installer_script:-}" ] && [ -f "${installer_script}" ]; then
    rm -f "${installer_script}"
  fi
}

trap cleanup EXIT INT TERM

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

# Validate GitHub username format
validate_github_username() {
  local username="$1"

  # GitHub username rules:
  # - alphanumeric and hyphens only
  # - cannot start or end with hyphen
  # - max 39 characters
  if ! printf '%s' "${username}" | grep -E -q '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,37}[a-zA-Z0-9])?$'; then
    error "Invalid GitHub username format: ${username}"
    error "Username must be alphanumeric with optional hyphens (max 39 chars)"
    return 1
  fi

  return 0
}

# Check if directory is writable, create if needed
ensure_directory_writable() {
  local dir="$1"

  if [ ! -d "${dir}" ]; then
    step "Creating directory: ${dir}"
    if ! mkdir -p "${dir}"; then
      error "Failed to create directory: ${dir}"
      error "Check permissions and available disk space"
      return 1
    fi
    chmod 755 "${dir}"
  fi

  if [ ! -w "${dir}" ]; then
    error "Directory not writable: ${dir}"
    error "Current permissions: $(ls -ld "${dir}" 2>/dev/null || echo 'unknown')"
    return 1
  fi

  return 0
}

# Download file with validation
download_file() {
  local url="$1"
  local output="$2"
  local downloader=""

  # Determine available downloader
  if command -v curl >/dev/null 2>&1; then
    downloader="curl"
  elif command -v wget >/dev/null 2>&1; then
    downloader="wget"
  else
    error "Neither curl nor wget found"
    error "Please install curl or wget to continue"
    return 1
  fi

  # Download with appropriate tool
  case "${downloader}" in
    curl)
      if ! curl -fsSL \
           --proto '=https' \
           --tlsv1.2 \
           --max-time "${INSTALL_TIMEOUT}" \
           -o "${output}" \
           "${url}"; then
        error "Download failed: ${url}"
        return 1
      fi
      ;;
    wget)
      if ! wget -q \
           --secure-protocol=TLSv1_2 \
           --timeout="${INSTALL_TIMEOUT}" \
           -O "${output}" \
           "${url}"; then
        error "Download failed: ${url}"
        return 1
      fi
      ;;
  esac

  return 0
}

#==============================================================================
# MAIN INSTALLATION LOGIC
#==============================================================================

install_chezmoi() {
  local chezmoi_path="${BIN_DIR}/chezmoi"

  info "chezmoi not found, installing to ${BIN_DIR}"

  # Ensure directory exists and is writable
  ensure_directory_writable "${BIN_DIR}" || return 1

  # Download installer script
  installer_script="$(mktemp)"
  step "Downloading chezmoi installer..."

  if ! download_file "${CHEZMOI_INSTALLER_URL}" "${installer_script}"; then
    error "Failed to download chezmoi installer"
    error "You can manually install from: https://www.chezmoi.io/install/"
    return 1
  fi

  # Execute installer
  step "Running chezmoi installer..."
  if ! sh "${installer_script}" -b "${BIN_DIR}"; then
    error "chezmoi installation failed"
    return 1
  fi

  # Verify installation
  if [ ! -x "${chezmoi_path}" ]; then
    error "chezmoi binary not found after installation: ${chezmoi_path}"
    return 1
  fi

  success "chezmoi installed successfully"
  info "Location: ${chezmoi_path}"
  info "Version: $(${chezmoi_path} --version 2>/dev/null || echo 'unknown')"

  return 0
}

check_or_install_chezmoi() {
  local chezmoi_cmd=""

  step "Checking for chezmoi installation..."

  if command -v chezmoi >/dev/null 2>&1; then
    chezmoi_cmd="chezmoi"
    success "chezmoi already installed"
    info "Location: $(command -v chezmoi)"
    info "Version: $(chezmoi --version 2>/dev/null || echo 'unknown')"
  else
    if ! install_chezmoi; then
      exit 1
    fi
    chezmoi_cmd="${BIN_DIR}/chezmoi"
  fi

  # Export for use in other functions
  readonly CHEZMOI_CMD="${chezmoi_cmd}"
}

run_chezmoi_command() {
  local choice="$1"
  local cmd_args=""

  case "${choice}" in
    1)
      cmd_args="init ${GITHUB_USERNAME}"
      ;;
    2)
      cmd_args="init ${GITHUB_USERNAME} --apply"
      ;;
    3)
      cmd_args="init ${GITHUB_USERNAME} --one-shot"
      ;;
    *)
      error "Invalid choice: ${choice}"
      return 1
      ;;
  esac

  info "Running: chezmoi ${cmd_args}"

  # Execute chezmoi command
  # Note: Using exec would prevent success message, so we run normally
  if ${CHEZMOI_CMD} ${cmd_args}; then
    printf "\n"
    success "chezmoi completed successfully! 🎉"
    printf "\n"
    return 0
  else
    local exit_code=$?
    error "chezmoi command failed with exit code ${exit_code}"
    return "${exit_code}"
  fi
}

interactive_menu() {
  step "Initializing chezmoi and applying dotfiles..."

  prompt "Select a command:"
  printf "    1) chezmoi init %s\n" "${GITHUB_USERNAME}"
  printf "    2) chezmoi init %s --apply\n" "${GITHUB_USERNAME}"
  printf "    3) chezmoi init %s --one-shot\n" "${GITHUB_USERNAME}"
  printf "    4) Quit\n"

  # Loop until valid input is provided
  while true; do
    printf "  Enter choice (1-4): "
    read -r next_cmd

    # Trim whitespace
    next_cmd="$(printf '%s' "${next_cmd}" | tr -d '[:space:]')"

    # Validate input format
    if ! printf '%s' "${next_cmd}" | grep -E -q '^[1-4]?$'; then
      warning "Invalid input format. Please enter a number between 1-4."
      continue
    fi

    case "${next_cmd}" in
      1|2|3)
        run_chezmoi_command "${next_cmd}"
        exit $?
        ;;
      4|"")
        info "Quit selected, exiting."
        exit 0
        ;;
      *)
        warning "Invalid choice '${next_cmd}'. Please select 1-4."
        ;;
    esac
  done
}

#==============================================================================
# MAIN EXECUTION
#==============================================================================

main() {
  header "chezmoi -> install, init and apply dotfiles"

  # Validate configuration
  if ! validate_github_username "${GITHUB_USERNAME}"; then
    exit 1
  fi

  # Check or install chezmoi
  check_or_install_chezmoi

  # Run interactive menu
  interactive_menu
}

# Execute main function
main "$@"
