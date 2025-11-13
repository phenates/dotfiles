<#
.SYNOPSIS
    Bootstrap script for Windows dotfiles installation using chezmoi

.DESCRIPTION
    This PowerShell script installs chezmoi binary using the official installer,
    then initializes and applies dotfiles from the GitHub repository.

.NOTES
    File Name   : install.ps1
    Author      : phenates
    Version     : 0.1.0
    Date        : 2025-01-12

.USAGE
    # Run from remote URL (recommended)
    irm https://dotfiles-win.votre-domaine.com/ | iex

    # Or directly from GitHub
    irm https://raw.githubusercontent.com/phenates/dotfiles/master/install.ps1 | iex

    # Or locally
    .\install.ps1

.LINK
    https://github.com/phenates/dotfiles
    https://www.chezmoi.io
#>

#Requires -Version 5.1

# Strict error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

#==============================================================================
# Variables
#==============================================================================

$GITHUB_USERNAME = "phenates"
$CHEZMOI_INSTALL_URL = "https://get.chezmoi.io/ps1"
$BINARY_DIR = Join-Path $env:USERPROFILE "bin"
$CHEZMOI_BINARY = Join-Path $BINARY_DIR "chezmoi.exe"

#==============================================================================
# Logging Functions (matching Linux install.sh style)
#==============================================================================

function Write-Header {
    param([string]$Message)

    Write-Host ""
    Write-Host "⮞  $Message" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
}

function Write-Info {
    param([string]$Message)

    Write-Host "  ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)

    Write-Host "  ✅  $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)

    Write-Host "  ⚠️  WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)

    Write-Host "  ❌  ERROR: $Message" -ForegroundColor Red
    [Console]::Error.WriteLine("  ❌  ERROR: $Message")
}

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "  ➜  $Message" -ForegroundColor Blue
}

function Write-Prompt {
    param([string]$Message)

    Write-Host ""
    Write-Host "  ❓  $Message" -ForegroundColor Yellow
}

#==============================================================================
# Main Script
#==============================================================================

try {
    Write-Header "chezmoi -> install, init and apply dotfiles"

    # Install chezmoi
    Write-Step "Installing chezmoi..."

    try {
        Write-Info "Downloading chezmoi installer from: $CHEZMOI_INSTALL_URL"
        Write-Info "Installing to: $BINARY_DIR"

        # Download and execute the official chezmoi installer
        $installScript = Invoke-RestMethod -Uri $CHEZMOI_INSTALL_URL -UseBasicParsing

        # Execute the installer script
        Invoke-Expression $installScript

        # Verify installation
        if (Test-Path -Path $CHEZMOI_BINARY) {
            Write-Success "chezmoi installed successfully"
        }
        else {
            Write-Error "Installation completed but binary not found at: $CHEZMOI_BINARY"
            exit 1
        }

    }
    catch {
        Write-Error "Failed to install chezmoi: $_"
        Write-Info "You can try installing manually:"
        Write-Info "  - Using winget: winget install twpayne.chezmoi"
        Write-Info "  - Using scoop: scoop install chezmoi"
        Write-Info "  - Using chocolatey: choco install chezmoi"
        exit 1
    }

    # Initialize and apply dotfiles with chezmoi
    Write-Step "Initializing chezmoi and applying dotfiles..."

    # Show menu and get user choice
    Write-Prompt "Select a command:"
    Write-Host "    1) chezmoi init $GITHUB_USERNAME"
    Write-Host "    2) chezmoi init $GITHUB_USERNAME --apply"
    Write-Host "    3) chezmoi init $GITHUB_USERNAME --one-shot"
    Write-Host "    4) Quit"

    # Get user choice
    $choice = Read-Host "  Enter choice (1-4)"

    # Execute the chosen command
    switch ($choice) {
        "1" {
            Write-Info "\nRunning: chezmoi init $GITHUB_USERNAME"
            & $CHEZMOI_BINARY init $GITHUB_USERNAME
        }
        "2" {
            Write-Info "Running: chezmoi init $GITHUB_USERNAME --apply"
            & $CHEZMOI_BINARY init $GITHUB_USERNAME --apply
        }
        "3" {
            Write-Info "Running: chezmoi init $GITHUB_USERNAME --one-shot"
            & $CHEZMOI_BINARY init $GITHUB_USERNAME --one-shot
        }
        "4" {
            Write-Info "Quit selected, exiting."
            exit 0
        }
        default {
            Write-Warning "Invalid choice '$choice'. Exiting."
            exit 1
        }
    }

}
catch {
    Write-Error "An unexpected error occurred: $_"
    Write-Error $_.ScriptStackTrace
    exit 1
}
