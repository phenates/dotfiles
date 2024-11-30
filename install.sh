#!/usr/bin/env bash
set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Usage display:
#/ Usage: ./install.sh [OPTION]
#/ Run command: sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
#/ Description: This script will install and initiate chezmoi package for the current user.
#/              chezmoi helps you manage your personal configuration files
#/              (dotfiles, like ~/.gitconfig) across multiple machines.
#/ Options:
#/   --help: Display this help message
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}
expr "$*" : ".*--help" >/dev/null && usage

## Variables:
SCRIPT_NAME=$(basename "$0")
ARG_1=${1:-"default"}
CMD_OPTION="-- init --apply phenates"

## Log (add "| tee -a "$LOG_FILE" >&2" to into a file):
info() { echo -e "\033[0;36m--->   $*"; }
warning() { echo -e "\033[1;33m--->[WARNING]   $*"; }
error() { echo -e "\033[0;31m--->[ERROR]   $*"; }

## Main
info "dotfiles management started   <---"
info "$SCRIPT_NAME : download binary chezmoi and initiate it"

# Check if chezmoi package is installed
if [ ! "$(command -v chezmoi)" ]; then
  # Download chezmoi binary file
  if [ "$(command -v wget)" ]; then
    wget -qO- get.chezmoi.io/
    # sh -c "$(wget -qO- get.chezmoi.io/)" $OPTION
  elif [ "$(command -v curl)" ]; then
    curl -fsLS get.chezmoi.io/
    # sh -c "$(curl -fsLS get.chezmoi.io/)" $OPTION
  else
    warning "To install chezmoi, you must have curl or wget installed."
    exit 1
  fi
  info "chezmoi binary file downloaded"
else
  info "chezmoi package already installed"
fi

# Init and apply chemoi from a github dotfiles repo
bash ~/bin/chezmoi "$CMD_OPTION"
info "chezmoi initiated & will be apply"
echo -e ""
