<#
.SYNOPSIS
    Utility functions for chezmoi scripts (PowerShell version)

.DESCRIPTION
    This module provides utility functions for logging and command validation
    in chezmoi scripts. It includes colored output functions with symbols
    and command existence checks.

.NOTES
    File Name   : utils.ps1
    Author      : phenates
    Version     : 0.1.0
    Date        : 2025-11-06

.EXAMPLE
    # Import the module in your scripts
    . "$HOME\.local\share\chezmoi\home\.utils\utils.ps1"

    # Use the logging functions
    Write-Header "Installation Process"
    Write-Step "Installing packages..."
    Write-Success "Installation completed"

.EXAMPLE
    # Check if commands exist
    if (Test-CommandExists "git") {
        Write-Success "Git is installed"
    }

    # Validate required tools
    if (Assert-RequiredTools @("git", "curl", "winget")) {
        Write-Success "All required tools are available"
    }
#>

# Log functions (enhanced with colors and symbols)

function Write-Header {
    param([string]$Message)

    Write-Host ""
    Write-Host ">>>  $Message" -ForegroundColor Magenta
    Write-Host "---------------------------------------------------" -ForegroundColor Magenta
}

function Write-Info {
    param([string]$Message)

    Write-Host "    Info:  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)

    Write-Host "    Success:  $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)

    Write-Host "    WARNING:  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)

    Write-Host "    ERROR: $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "  ->  $Message" -ForegroundColor Blue
}

function Write-Prompt {
    param([string]$Message)

    Write-Host ""
    Write-Host "  ?  $Message" -ForegroundColor Yellow
}

# Check if a command exists
function Test-CommandExists {
    param([string]$Command)

    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Validate that required tools are available
function Assert-RequiredTools {
    param([string[]]$Tools)

    $missingTools = @()

    foreach ($tool in $Tools) {
        if (-not (Test-CommandExists $tool)) {
            $missingTools += $tool
        }
    }

    if ($missingTools.Count -gt 0) {
        Write-Warning "Required tools missing: $($missingTools -join ', ')"
        Write-Info "Please install missing tools and try again"
        return $false
    }

    return $true
}

# Note: Functions are automatically available when this script is dot-sourced
# No need for Export-ModuleMember when using dot sourcing (. script.ps1)
