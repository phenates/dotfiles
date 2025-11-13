#!/bin/bash

#==============================================================================
#description  :Utility fonctions for chezmoi scripts
#usage		  :Source this files in scripts: source "{{ .chezmoi.sourceDir -}}/.utils/utils.sh"
#version      :0.1
#date         :2025-10-24
#==============================================================================

# Log (enhanced with colors and symbols)
header() {
  echo -e "\n\033[1;35m⮞  $*\033[0m"
  echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

info() { echo -e "\033[1;36m  ℹ️  $*\033[0m"; }

success() { echo -e "\033[1;32m  ✅  $*\033[0m"; }

warning() { echo -e "\033[1;33m  ⚠️  WARNING: $*\033[0m"; }

error() { echo -e "\033[1;31m  ❌  ERROR: $*\033[0m" >&2; }

step() { echo -e "\n\033[1;34m  ➜  $*\033[0m"; }

prompt() { printf "\n\033[1;33m  ❓  %s\n\033[0m" "$*"; }

# Check if a command exists and is executable
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate that required tools are available
require_tools() {
    local MISSING_TOOLS=()
    
    for TOOL in "$@"; do
        if ! command_exists "$TOOL"; then
            MISSING_TOOLS+=("$TOOL")
        fi
    done
    
    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        warning "Required tools missing: ${MISSING_TOOLS[*]}"
        info "Please install missing tools and try again"
        return 1
    fi
    
    return 0
}