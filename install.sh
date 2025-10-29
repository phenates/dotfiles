#!/bin/bash

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
  echo -e "\033[1;35m⮞  $*\033[0m"
  echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

info() { echo -e "\033[1;36m  ℹ️  $*\033[0m"; }

success() { echo -e "\033[1;32m  ✅  $*\033[0m"; }

warning() { echo -e "\033[1;33m  ⚠️  WARNING: $*\033[0m"; }

error() { echo -e "\033[1;31m  ❌  ERROR: $*\033[0m" >&2; }

step() { echo -e "\n\033[1;34m  ➜  $*\033[0m"; }

ask_yN() {
  local question="$1"
  local response
  
  echo -e -n "\033[1;33m  ?  $question (y/N): \033[0m"
  read -r response
  
  case "$response" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

## Main
header "chezmoi dotfiles manager\n \
  install, init and apply dotfiles"

# Check if chezmoi is already installed, if not install it
step "Checking for chezmoi installation..."
if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  info "chezmoi not found, installing it to $bin_dir"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
    success "chezmoi installed"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
    success "chezmoi installed"
  else
    error "Neither wget nor curl is installed"
    error "Please install one of them: sudo apt install curl wget"
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# Init and apply dotfiles with chezmoi
step "Initializing and applying dotfiles with chezmoi..."
# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

info "script_dir: $script_dir"

NEXT_CMD=$(whiptail \
  --menu "Command to run:" \
  --title "Do you want to init & apply chezmoi ?" \
  15 60 4 \
  "1" "Init" \
  "2" "Init and Apply" \
  "3" "Init and Apply --one-shot" \
  "4" "Quit" \
  3>&1 1>&2 2>&3)

if [ "$NEXT_CMD" = "1" ]; then
  info "Running: chezmoi init $GITHUB_USERNAME"
  $chezmoi init "$GITHUB_USERNAME"
elif [ "$NEXT_CMD" = "2" ]; then
  info "Running: chezmoi init --apply $GITHUB_USERNAME"
  $chezmoi init --apply "$GITHUB_USERNAME"
elif [ "$NEXT_CMD" = "3" ]; then
  info "Running: chezmoi init --apply $GITHUB_USERNAME"
  $chezmoi init --apply "$GITHUB_USERNAME" --one-shot
else
  info "Quit selected, exiting."
  exit 0
fi

echo ""
success "chezmoi completed! 🎉"
echo ""
