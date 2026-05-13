#!/bin/bash

#==============================================================================
#description  :Utility functions for chezmoi scripts
#usage        :source "{{ .chezmoi.sourceDir -}}/.utils/utils.sh"
#version      :0.2
#date         :2025-10-24
#==============================================================================

# Colors
PURPLE='\033[1;35m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

header()  { echo -e "\n${PURPLE}===== $* =====${NC}"
            echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
step()    { echo -e "${BLUE}  -->  $*${NC}"; }
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR ]${NC}  $*" >&2; }

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
