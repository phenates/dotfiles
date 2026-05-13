<#
.SYNOPSIS
    Bootstrap script for Windows dotfiles installation using chezmoi

.DESCRIPTION
    Installs chezmoi then initializes and applies dotfiles from the GitHub
    repository. Non-interactive by design.

.NOTES
    File Name   : install.ps1
    Author      : phenates
    Version     : 0.2.0
    Date        : 2025-10-23

.USAGE
    # Run directly from GitHub
    irm https://raw.githubusercontent.com/phenates/dotfiles/master/install.ps1 | iex

    # Or locally
    .\install.ps1

.LINK
    https://github.com/phenates/dotfiles
    https://www.chezmoi.io
#>

#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$GITHUB_USERNAME = "phenates"
$BINARY_DIR      = Join-Path $env:USERPROFILE "bin"
$CHEZMOI_BINARY  = Join-Path $BINARY_DIR "chezmoi.exe"

if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "chezmoi not found, installing to $BINARY_DIR"
    $installScript = Invoke-RestMethod -Uri "https://get.chezmoi.io/ps1" -UseBasicParsing
    Invoke-Expression $installScript
    $chezmoi = $CHEZMOI_BINARY
} else {
    $chezmoi = "chezmoi"
}

& $chezmoi init $GITHUB_USERNAME --apply
exit $LASTEXITCODE
