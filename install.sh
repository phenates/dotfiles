#!/bin/sh

#==============================================================================
#title            :install.sh
#description      :Installs chezmoi then initializes and applies dotfiles
#                  from the GitHub repository. Non-interactive by design.
#author           :phenates
#date             :2025-10-23
#version          :0.5
#usage            :sh -c "$(curl -fsLS https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
#==============================================================================

set -e

GITHUB_USERNAME="phenates"

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

exec "$chezmoi" init "$GITHUB_USERNAME" --apply
