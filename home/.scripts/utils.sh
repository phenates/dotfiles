#!/bin/bash

#==============================================================================
#description  :Utility fonctions for chezmoi scripts
#usage		    :Source this files in scripts: source "{{ .chezmoi.sourceDir -}}/.scripts/utils.sh"
#version      :0.1
#date         :2025-10-24
#==============================================================================

## Log (enhanced with colors and symbols)
header() {
  echo -e "\033[1;35m⮞  $*\033[0m"
  echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

info() { echo -e "\033[1;36m  ℹ️  $*\033[0m"; }

success() { echo -e "\033[1;32m  ✅  $*\033[0m"; }

warning() { echo -e "\033[1;33m  ⚠️  WARNING: $*\033[0m"; }

error() { echo -e "\033[1;31m  ❌  ERROR: $*\033[0m" >&2; }

step() { echo -e "\n\033[1;34m  ➜  $*\033[0m"; }