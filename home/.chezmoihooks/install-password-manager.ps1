#Requires -Version 5.1

<#
.SYNOPSIS
    Chezmoi hook script to install Bitwarden CLI on Windows.

.DESCRIPTION
    This hook runs after chezmoi init has cloned dotfile repo but before chezmoi
    has read the source state. The script ensures that Bitwarden CLI is installed
    before chezmoi uses it to apply templates that may depend on it.

.NOTES
    Version:      0.3
    Date:         2025-10-25
    Hook Type:    hooks.read-source-state.pre
#>

#==============================================================================
# Exit immediately if bw is already in PATH
#==============================================================================
if (Get-Command bw -ErrorAction SilentlyContinue) {
    exit 0
}

#==============================================================================
# Source utility functions
#==============================================================================
. "$HOME\.local\share\chezmoi\home\.utils\utils.ps1"

#==============================================================================
# Error Handling
#==============================================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # Faster downloads

#==============================================================================
# Variables
#==============================================================================
$BIT_BIN_CMD = "bw.exe"
$BIT_BIN_URL = "https://github.com/bitwarden/clients/releases/download/cli-v2025.10.0/bw-windows-2025.10.0.zip"
$BIT_BIN_SHA256 = "81ad1eb3cc97dbb0ea251f7e23fb7f327fbf2c06f985d621d7974bfb8ef748a1"
# Use Windows standard location that's typically in PATH
$INSTALL_DIR = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$TEMP_DIR = Join-Path $env:TEMP "bwinstall_$(Get-Random)"
$BIT_BIN_PATH = Join-Path $INSTALL_DIR $BIT_BIN_CMD
$CONFIG_DIR = "$env:APPDATA\Bitwarden CLI"

#==============================================================================
# Additional Helper Functions
#==============================================================================
function Get-FileHashSHA256 {
    param([string]$FilePath)
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash.ToLower()
}

#==============================================================================
# Cleanup Function
#==============================================================================
function Remove-TempDirectory {
    if (Test-Path $TEMP_DIR) {
        try {
            Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction Stop
            Write-Success "Temporary files removed successfully"
        }
        catch {
            Write-Warning "Failed to remove temporary files: $_"
        }
    }
}

#==============================================================================
# Main Script
#==============================================================================
try {
    Write-Header "chezmoi -> Private mode enabled`n  Bitwarden CLI installation & configuration"

    # Create temporary directory
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null

    # Check required tools
    Write-Step "Tools validation..."
    if (-not (Assert-RequiredTools @('Expand-Archive'))) {
        exit 1
    }
    Write-Success "Required tools available"

    # Download Bitwarden binary
    Write-Step "Bitwarden CLI installation..."
    $zipPath = Join-Path $TEMP_DIR "$BIT_BIN_CMD.zip"

    try {
        Write-Info "Downloading from: $BIT_BIN_URL"
        Invoke-WebRequest -Uri $BIT_BIN_URL -OutFile $zipPath -UseBasicParsing
    }
    catch {
        Write-Error "Failed to download package from: $BIT_BIN_URL"
        exit 1
    }

    # Verify SHA256 checksum
    Write-Step "Verifying checksum..."
    $downloadedSHA256 = Get-FileHashSHA256 -FilePath $zipPath

    if ($downloadedSHA256 -ne $BIT_BIN_SHA256.ToLower()) {
        Write-Error "Checksum verification failed!"
        Write-Error "Expected: $BIT_BIN_SHA256"
        Write-Error "Got: $downloadedSHA256"
        exit 1
    }
    Write-Success "Binary file downloaded and verified successfully"

    # Create installation directory
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }

    # Extract binary
    Write-Step "Extracting binary..."
    try {
        Expand-Archive -Path $zipPath -DestinationPath $INSTALL_DIR -Force
        Write-Success "Package extracted successfully to: $INSTALL_DIR"
    }
    catch {
        Write-Error "Failed to extract binary package: $_"
        exit 1
    }

    # Verify binary is executable
    if (-not (Test-Path $BIT_BIN_PATH)) {
        Write-Error "Binary not found at: $BIT_BIN_PATH"
        exit 1
    }
    Write-Success "Binary installed successfully"

    # WindowsApps is typically already in PATH, but verify
    Write-Step "Verifying PATH configuration..."
    if ($env:Path -notlike "*$INSTALL_DIR*") {
        Write-Warning "WindowsApps not in current PATH, this is unusual"
        # Add to current session
        $env:Path = "$env:Path;$INSTALL_DIR"
    }

    # Verify bw is now accessible
    if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
        Write-Error "bw command not found in PATH after installation"
        Write-Info "Install location: $BIT_BIN_PATH"
        Write-Info "Please restart your terminal or PowerShell session"
        exit 1
    }
    Write-Success "bw command is available in PATH"

    # Cleanup temporary files
    Write-Step "Cleaning up temporary files..."
    Remove-TempDirectory

    # Configure Bitwarden server URL
    Write-Step "Configuring Bitwarden server URL..."

    do {
        $url = Read-Host "  Enter the Bitwarden server URL (default: https://vault.bitwarden.eu)"

        # Use default if empty
        if ([string]::IsNullOrWhiteSpace($url)) {
            $url = "https://vault.bitwarden.eu"
            break
        }

        # Trim whitespace
        $url = $url.Trim()

        # Validate URL format
        if ($url -match '^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$') {
            break
        }
        else {
            Write-Warning "Invalid URL format. Please enter a valid URL (e.g., https://vault.bitwarden.eu)"
        }
    } while ($true)

    Write-Info "Using server URL: $url"
    try {
        & $BIT_BIN_PATH config server $url | Out-Null
        Write-Success "Server URL set successfully to: $CONFIG_DIR\data.json"
    }
    catch {
        Write-Error "Failed to set server URL: $_"
        exit 1
    }

    # Login to Bitwarden
    Write-Step "Login to your Bitwarden account"
    Write-Info "Please enter your Bitwarden credentials when prompted..."

    try {
        $session = & $BIT_BIN_PATH login --raw
        if ($LASTEXITCODE -ne 0) {
            throw "Login failed with exit code $LASTEXITCODE"
        }
        Write-Success "Logged into Bitwarden successfully"
    }
    catch {
        Write-Error "Failed to login to Bitwarden: $_"
        exit 1
    }
    finally {
        # Clear sensitive variables
        Remove-Variable -Name url -ErrorAction SilentlyContinue
        Remove-Variable -Name session -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Success "Bitwarden CLI installation & configuration completed!"
    Write-Host ""
}
catch {
    Write-Error "An unexpected error occurred: $_"
    Remove-TempDirectory
    exit 1
}
finally {
    # Final cleanup
    Remove-TempDirectory
}
