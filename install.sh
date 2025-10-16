#!/bin/bash

#==============================================================================
#title            :install.sh
#description      :This bash script install chezmoi binary file for the operating system and architecture in ./bin.
#author		        :phenates
#date             :2025-10-15
#version          :0.3
#usage		        :sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
#==============================================================================

set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Variables:
SCRIPT_NAME=$(basename "$0")
CMD_OPTION="-- init --apply phenates"

## Log (enhanced with colors and symbols):
header() {
  echo -e "\n\033[1;35m****************************************************\033[0m"
  echo -e "\033[1;35m    $*\033[0m"
  echo -e "\033[1;35m****************************************************\033[0m"
}

info() {
  echo -e "\033[1;36m  ℹ  $*\033[0m"
}

success() {
  echo -e "\033[1;32m  ✓  $*\033[0m"
}

warning() {
  echo -e "\033[1;33m  ⚠  WARNING: $*\033[0m"
}

error() {
  echo -e "\033[1;31m  ✗  ERROR: $*\033[0m" >&2
}

step() {
  echo -e "\n\033[1;34m  →  $*\033[0m"
}

## Main
header "chezmoi dotfiles manager\n install, init and apply dotfiles"

#TODO Check if sudo

info "test info"
success "test success"
warning "test warning"
error "test error"
step "test step"

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
    error "Please install one of them: sudo apt install wget"
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# Init and apply dotfiles with chezmoi
step "Initializing and applying dotfiles with chezmoi..."
# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
# script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
# info "Using dotfiles source directory: $script_dir"
# exec: replace current process with chezmoi init
# exec "$chezmoi" init --apply "--source=$script_dir"
$chezmoi init --apply phenates

header "chezmoi dotfiles manager\n ✓ dotfiles installation finished successfully!"
echo -e ""
