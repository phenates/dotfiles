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
# ARG_1=${1:-"default"}
CMD_OPTION="-- init --apply phenates"

## Log (add "| tee -a "$LOG_FILE" >&2" to into a file):
info() { echo -e "\033[0;36m $*"; }
warning() { echo -e "\033[1;33m--->[WARNING]   $*"; }

## Main
info "<<<<< dotfiles management started >>>>>"
info ">>> chezmoi download binary file, init & apply"

#TODO Check if sudo

# Download chezmoi binary file and run with option
if [ "$(command -v wget)" ]; then
  # wget -qO- get.chezmoi.io/
  sh -c "$(wget -qO- get.chezmoi.io/)" $CMD_OPTION
elif [ "$(command -v curl)" ]; then
  # curl -fsLS get.chezmoi.io/
  sh -c "$(curl -fsLS get.chezmoi.io/)" $CMD_OPTION
else
  warning "To install chezmoi, you must have curl or wget installed."
  exit 1
fi

info "<<<<< dotfiles management finished >>>>>"
echo -e ""
