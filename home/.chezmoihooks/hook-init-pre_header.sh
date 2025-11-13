#!/bin/bash

#==============================================================================
#description  :chezmoi hook (hooks.init.pre) script.
#              This hook running before chezmoi init.
#              The script just display a header.
#version      :0.1
#date         :2025-10-28
#==============================================================================

# Source utility functions
source "$HOME/.local/share/chezmoi/home/.utils/utils.sh"

set -euo pipefail # Strict error handling

## Main
header "chezmoi -> machine configuration"

