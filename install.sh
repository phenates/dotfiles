#!/bin/sh

#==============================================================================
#title            :install.sh
#description      :This bash script install chezmoi binary file in .local/bin, then
#                  initializes and applies dotfiles from the GitHub repository.
#author		        :phenates
#date             :2025-10-23
#version          :0.4
#usage		        :sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
#==============================================================================

set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Variables:
GITHUB_USERNAME="phenates"

## Log (enhanced with colors and symbols):
header() {
  printf "\n\033[1;35m⮞  %s\n\033[0m" "$*"
  printf "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\033[0m"
}

info() { printf "\033[1;36m  ℹ️  %s\n\033[0m" "$*"; }

success() { printf "\033[1;32m  ✅  %s\n\033[0m" "$*"; }

warning() { printf "\033[1;33m  ⚠️  WARNING: %s\n\033[0m" "$*"; }

error() { printf "\033[1;31m  ❌  ERROR: %s\n\033[0m" "$*" >&2; }

step() { printf "\n\033[1;34m  ➜  %s\n\033[0m" "$*"; }

prompt() { printf "\n\033[1;33m  ❓  %s\n\033[0m" "$*"; }

## Main
header "chezmoi -> install, init and apply dotfiles"

# Check if chezmoi is already installed, if not install it
step "Checking for chezmoi installation..."
if ! command -v chezmoi >/dev/null 2>&1; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  info "chezmoi not found, installing it to $bin_dir"

  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
    success "chezmoi installed"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$bin_dir"
    success "chezmoi installed"
  else
    error "To install chezmoi, you must have curl or wget installed."      
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# Init and apply dotfiles with chezmoi
step "Initializing chezmoi and applying dotfiles..."

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
# script_dir can be used within --source flag to indicate the chezmoi source directory.
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)" # CC correction for local execution only

info "Script dir.: $script_dir"

prompt "Select an command:"
printf "    1) chezmoi init %s\n" "$GITHUB_USERNAME"
printf "    2) chezmoi init %s --apply\n" "$GITHUB_USERNAME"
printf "    3) chezmoi init %s --one-shot\n" "$GITHUB_USERNAME"
printf "    4) Quit\n"

# Loop until valid input is provided
while true; do
  printf "  Enter choice (1-4): "
  read -r NEXT_CMD
  printf ""

  case "$NEXT_CMD" in
    1)
      info "Running: chezmoi init $GITHUB_USERNAME"
      exec $chezmoi init "$GITHUB_USERNAME"
      ;;
    2)
      info "Running: chezmoi init $GITHUB_USERNAME --apply"
      exec $chezmoi init "$GITHUB_USERNAME" --apply
      ;;
    3)
      info "Running: chezmoi init $GITHUB_USERNAME --one-shot"
      exec $chezmoi init "$GITHUB_USERNAME" --one-shot
      ;;
    4|"")
      info "Quit selected, exiting."
      exit 0
      ;;
    *)
      warning "Invalid choice '$NEXT_CMD'. Please select 1-4."
      ;;
  esac
done
