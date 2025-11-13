### Alias

## General aliases
# -----------------------------------------------------------------------------

# Clears the console screen.
Set-Alias -Name "c" -Value "Clear-Host" -Description "Clear console"

## Directory browsing
# -----------------------------------------------------------------------------
function l { eza --all --long --header --icons=auto }
function ll { eza --all --long --header --tree --level=2 --color=always --icons=auto }
function lll { eza --all --long --header --tree --color=always --icons=auto }

# yazi wrapper that provides the ability to change the current working directory when exiting Yazi.
# Use 'y' instead of yazi to start, and press 'q' to quit with change directory, press 'Q' to quit whitout.
function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}

### Fastfetch
fastfetch --config "$env:USERPROFILE\.config\fastfetch\config.jsonc"

### Oh-My-Posh
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\ohmyposh\omp-mytheme.json" | Invoke-Expression