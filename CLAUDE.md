# CLAUDE.md - AI Agent Instructions for Dotfiles Repository

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Architecture & Key Components](#-architecture--key-components)
3. [File Naming Conventions](#-file-naming-conventions)
4. [Template System](#-template-system)
5. [Scripts & Hooks](#-scripts--hooks)
6. [Development Workflows](#-development-workflows)
7. [Common Patterns & Best Practices](#-common-patterns--best-practices)
8. [Testing & Validation](#-testing--validation)
9. [Security Considerations](#-security-considerations)
10. [Platform-Specific Guidance](#-platform-specific-guidance)
11. [Quick Reference](#-quick-reference)

---

## 🎯 Project Overview

This repository uses [chezmoi](https://www.chezmoi.io) to manage dotfiles across multiple Linux distributions with support for:

- **Tag-based configuration**: core, core+, dev, sysAdmin, devOps, personal, work
- **Private mode**: Bitwarden CLI integration for secrets management
- **Multi-shell support**: Bash and Zsh configurations
- **WSL detection**: Windows Subsystem for Linux specific configurations

**Installation**:
```bash
sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
```

---

## 🏗️ Architecture & Key Components

### Directory Structure

```
dotfiles/
├── install.sh                           # Bootstrap installation script
├── home/                                # Chezmoi source directory (→ ~/)
│   ├── .chezmoi.yaml.tmpl              # Main configuration with prompts
│   ├── .chezmoiexternal.yaml.tmpl      # External dependencies (omz, plugins)
│   ├── .chezmoiignore                  # Conditional ignore patterns
│   ├── .chezmoihooks/                  # Pre/post hooks
│   │   ├── hook-init-pre_header.sh
│   │   └── install-password-manager.sh
│   ├── .chezmoiscripts/linux/          # Installation scripts
│   │   ├── run_onchange_before_10_install-packages.sh.tmpl
│   │   ├── run_onchange_after_10_chezmoi-package_install.sh.tmpl
│   │   └── run_onchange_after_50_shell-zsh.sh.tmpl
│   ├── .scripts/                       # Shared utilities
│   │   └── utils.sh
│   ├── dot_bashrc                      # Bash configuration
│   ├── dot_zshrc                       # Zsh configuration
│   ├── dot_sh_aliases.tmpl             # Shared shell aliases
│   ├── dot_sh_functions.tmpl           # Shared shell functions
│   ├── dot_nanorc                      # Nano editor config
│   ├── dot_p10k.zsh                    # Powerlevel10k theme
│   ├── private_dot_gitconfig.tmpl      # Git configuration (private)
│   ├── dot_config/                     # XDG config directory
│   │   ├── fastfetch/config.jsonc
│   │   ├── neofetch/config.conf
│   │   └── yazi/yazi.toml
│   ├── dot_local/                      # User-local files
│   │   ├── bin/.chezmoiexternal.yaml.tmpl    # Binary downloads
│   │   └── share/.chezmoiexternal.yaml.tmpl  # Fonts, themes
│   ├── dot_ssh/                        # SSH configuration
│   │   ├── config
│   │   ├── private_id_*.tmpl           # Private SSH keys
│   │   └── id_*.pub.tmpl               # Public SSH keys
│   └── dot_oh-my-zsh/                  # Oh-My-Zsh customization
│       ├── completions/_chezmoi.tmpl
│       └── custom/.chezmoiexternal.yaml.tmpl
```

### Initialization Flow

```
install.sh → chezmoi init → prompts → hooks → scripts → apply
```

1. **Install/verify chezmoi binary** (`~/.local/bin/chezmoi`)
2. **Interactive prompts** for configuration (private mode, tags, SSH keys)
3. **Execute hooks** (install password manager if private mode)
4. **Run scripts** (install packages, configure shell)
5. **Apply dotfiles** to home directory

### Template Variables

Defined in `.chezmoi.yaml.tmpl`:

| Variable                | Type   | Description              | Example                       |
| ----------------------- | ------ | ------------------------ | ----------------------------- |
| `.name`                 | string | User name                | `phenates`                    |
| `.email`                | string | Email address            | `phen4tes@gmail.com`          |
| `.private`              | bool   | Private mode flag        | `true`/`false`                |
| `.environmentTags`      | list   | Machine environment tags | `["core", "dev"]`             |
| `.secretsTags`          | list   | SSH keys to install      | `["id_github", "id_homelab"]` |
| `.installZSH`           | bool   | Install ZSH              | `true`/`false`                |
| `.changeShell`          | bool   | Change default shell     | `true`/`false`                |
| `.OS_id`                | string | OS identifier            | `linux-debian`                |
| `.is_WSL`               | bool   | WSL detection            | `true`/`false`                |
| `.chezmoi.os`           | string | Operating system         | `linux`/`darwin`              |
| `.chezmoi.arch`         | string | Architecture             | `amd64`/`arm64`               |
| `.chezmoi.hostname`     | string | Hostname                 | `myserver`                    |
| `.chezmoi.username`     | string | Current user             | `phenates`                    |
| `.chezmoi.osRelease.id` | string | Distribution ID          | `debian`/`fedora`             |

---

## 📝 File Naming Conventions

### Chezmoi Prefixes

| Prefix          | Purpose            | Example                         | Target                |
| --------------- | ------------------ | ------------------------------- | --------------------- |
| `dot_`          | Regular dotfiles   | `dot_bashrc`                    | `~/.bashrc`           |
| `private_dot_`  | Sensitive dotfiles | `private_dot_gitconfig.tmpl`    | `~/.gitconfig`        |
| `executable_`   | Executable files   | `executable_script.sh`          | Executable script     |
| `run_once_`     | Run once scripts   | `run_once_install.sh`           | One-time execution    |
| `run_onchange_` | Run on change      | `run_onchange_packages.sh.tmpl` | When template changes |
| `.tmpl`         | Template files     | `dot_sh_aliases.tmpl`           | Dynamic content       |

### Script Naming Pattern

Format: `{frequency}_{timing}_{order}_{description}.sh.tmpl`

**Frequency**:
- `run_once_` - Execute only once
- `run_onchange_` - Execute when file content changes

**Timing**:
- `before` - Before chezmoi operations
- `after` - After chezmoi operations

**Order**: Numeric (10, 20, 30... for execution sequence)

**Examples**:
- `run_onchange_before_10_install-packages.sh.tmpl`
- `run_onchange_after_10_chezmoi-package_install.sh.tmpl`
- `run_onchange_after_50_shell-zsh.sh.tmpl`

---

## 🎨 Template System

### Template Files

Files with `.tmpl` extension support Go template syntax with chezmoi functions:

```go
{{- if .private -}}
# Private mode enabled - load secrets from Bitwarden
{{ bitwarden "item" "GitHub Token" }}
{{- end }}

{{- if has "dev" .environmentTags -}}
# Development tools enabled
export PATH="$HOME/.local/bin:$PATH"
{{- end }}

{{- if .is_WSL -}}
# WSL-specific configuration
alias ssh-add='ssh-add.exe'
{{- end }}
```

### Conditional Logic Patterns

**OS Detection**:
```go
{{- if eq .chezmoi.os "linux" -}}
# Linux-specific configuration
{{- else if eq .chezmoi.os "darwin" -}}
# macOS-specific configuration
{{- end -}}
```

**Distribution Check**:
```go
{{- if eq .OS_id "linux-debian" -}}
# Debian/Ubuntu specific
{{- else if eq .OS_id "linux-fedora" -}}
# Fedora/RHEL specific
{{- end -}}
```

**Tag-based Inclusion**:
```go
{{- if has "core+" .environmentTags -}}
# Install enhanced tools like yazi
{{- end -}}
```

**Multi-condition**:
```go
{{- if and .private (has "work" .environmentTags) -}}
# Work-specific private configuration
{{- end -}}
```

### External Sources

Template for downloading binaries/archives in `.chezmoiexternal.yaml.tmpl`:

```yaml
".local/bin/tool":
  type: "archive-file"  # or "file"
  url: "{{ gitHubLatestReleaseAssetURL "owner/repo" "pattern" }}"
  executable: true
  refreshPeriod: "168h"  # 1 week
  stripComponents: 1
```

**Example** (fastfetch):
```yaml
".local/bin/fastfetch":
  type: "file"
  url: "{{ gitHubLatestReleaseAssetURL "fastfetch-cli/fastfetch" (printf "fastfetch-%s-%s" .chezmoi.os .chezmoi.arch) }}"
  executable: true
  refreshPeriod: "168h"
```

---

## 🔧 Scripts & Hooks

### Shared Utilities (`home/.scripts/utils.sh`)

**Logging Functions**:
```bash
header "Section Title"        # Magenta header with separator
info "Information message"    # Cyan info with ℹ️
success "Success message"     # Green success with ✅
warning "Warning message"     # Yellow warning with ⚠️
error "Error message"         # Red error with ❌ (stderr)
step "Processing step"        # Blue step indicator with ➜
prompt "User prompt"          # Yellow prompt with ❓
```

**Utility Functions**:
```bash
command_exists "cmd"          # Check if command exists in PATH
require_tools "cmd1" "cmd2"   # Validate multiple tools, error if missing
```

**Usage**:
```bash
# Always source at the beginning of scripts
source "$HOME/.local/share/chezmoi/home/.scripts/utils.sh"

# Example usage
step "Installing packages..."
if command_exists apt; then
  success "APT package manager found"
else
  error "APT not found"
  exit 1
fi
```

### Hook Types

**`hooks.init.pre`** - Before chezmoi init
- **Example**: `hook-init-pre_header.sh` (display welcome message)
- **Purpose**: User feedback, environment checks

**`hooks.read-source-state.pre`** - Before reading source state
- **Example**: `install-password-manager.sh` (install Bitwarden CLI)
- **Purpose**: Install dependencies needed for template rendering

### Script Patterns

**Package Installation Template**:
```bash
#!/bin/bash
source "$HOME/.local/share/chezmoi/home/.scripts/utils.sh"
set -euo pipefail

step "Detecting package manager..."

# Detect package manager
local pkg_manager=""
if command -v apt &> /dev/null; then
  pkg_manager="apt"
elif command -v dnf &> /dev/null; then
  pkg_manager="dnf"
elif command -v pacman &> /dev/null; then
  pkg_manager="pacman"
fi

# Define packages based on environment tags
{{- if has "core" .environmentTags }}
packages="git vim curl wget"
{{- end }}

{{- if has "dev" .environmentTags }}
packages="$packages docker nodejs python3"
{{- end }}

# Install based on package manager
case "$pkg_manager" in
  apt)
    step "Updating package list..."
    sudo apt update
    step "Installing packages..."
    sudo apt install -y $packages
    success "Packages installed successfully"
    ;;
  dnf)
    step "Installing packages..."
    sudo dnf install -y $packages
    success "Packages installed successfully"
    ;;
  pacman)
    step "Installing packages..."
    sudo pacman -S --noconfirm $packages
    success "Packages installed successfully"
    ;;
  *)
    error "No supported package manager found"
    exit 1
    ;;
esac
```

---

## 🔄 Development Workflows

### Making Changes

1. **Edit source files** in `home/` directory
   ```bash
   chezmoi edit ~/.bashrc
   # or directly edit
   nano home/dot_bashrc
   ```

2. **Test templates**:
   ```bash
   chezmoi execute-template < home/dot_sh_aliases.tmpl
   ```

3. **Preview changes**:
   ```bash
   chezmoi diff
   ```

4. **Apply changes**:
   ```bash
   chezmoi apply --dry-run    # Test first
   chezmoi apply              # Actually apply
   ```

5. **Commit changes**:
   ```bash
   cd ~/.local/share/chezmoi
   git add .
   git commit -m "feat: description"
   git push
   ```

6. **Update remote**:
   ```bash
   chezmoi update    # Pulls from git + applies
   ```

### Adding New Tools

1. **Create config** in `home/dot_config/tool/`
   ```bash
   mkdir -p home/dot_config/tool
   touch home/dot_config/tool/config.yml
   ```

2. **Add binary** to `home/dot_local/bin/.chezmoiexternal.yaml.tmpl`
   ```yaml
   ".local/bin/tool":
     type: "file"
     url: "https://example.com/tool-binary"
     executable: true
   ```

3. **Update `.chezmoiignore`** if conditional
   ```
   {{ if not (has "dev" .environmentTags) }}
   .config/tool/
   {{ end }}
   ```

4. **Add installation script** in `.chezmoiscripts/linux/`
   ```bash
   # run_onchange_before_20_install-tool.sh.tmpl
   {{ if has "dev" .environmentTags -}}
   # Install tool dependencies
   {{ end -}}
   ```

5. **Update package lists** if needed

### Adding Shell Aliases/Functions

**Aliases**: Edit `home/dot_sh_aliases.tmpl`
```bash
# General aliases
alias ll='ls -lah'
alias grep='grep --color=auto'

# Conditional aliases
{{- if .is_WSL }}
alias explorer='explorer.exe'
alias clip='clip.exe'
{{- end }}

{{- if has "dev" .environmentTags }}
alias dc='docker-compose'
alias k='kubectl'
{{- end }}
```

**Functions**: Edit `home/dot_sh_functions.tmpl`
```bash
# System update function
function upup() {
  # Detect package manager and update system
  local pkg_manager=""
  if command -v apt &> /dev/null; then
    pkg_manager="apt"
  elif command -v dnf &> /dev/null; then
    pkg_manager="dnf"
  elif command -v pacman &> /dev/null; then
    pkg_manager="pacman"
  fi

  case "$pkg_manager" in
    apt)
      sudo apt update && sudo apt upgrade -y
      ;;
    dnf)
      sudo dnf upgrade -y
      ;;
    pacman)
      sudo pacman -Syu
      ;;
  esac
}
```

### Adding SSH Keys

1. **Store private key** in Bitwarden vault
   - Item name: `SSH_KEY_NAME`
   - Field: Store the private key content

2. **Add private key template**: `home/dot_ssh/private_id_NAME.tmpl`
   ```go
   {{ bitwarden "item" "SSH_KEY_NAME" }}
   ```

3. **Add public key**: `home/dot_ssh/id_NAME.pub.tmpl`
   ```go
   {{ bitwarden "fields" "SSH_KEY_NAME" "public_key" }}
   ```

4. **Update `.chezmoiignore`** conditional
   ```
   {{ if not (has "id_NAME" .secretsTags) }}
   .ssh/id_NAME
   .ssh/id_NAME.pub
   {{ end }}
   ```

5. **Add to selection prompts** in `.chezmoi.yaml.tmpl`
   ```go
   {{- if $private -}}
   {{-   $secretsTags_choices := list "id_homelab" "id_github" "id_phenates" "id_NAME" -}}
   {{-   $secretsTags = promptMultichoice "SSH keys to add" $secretsTags_choices -}}
   {{- end -}}
   ```

---

## ✅ Common Patterns & Best Practices

### Template Best Practices

1. **Use `lookPath` for command checks** (safer in templates):
   ```go
   {{- if lookPath "docker" -}}
   # Docker is available
   export DOCKER_HOST=unix:///var/run/docker.sock
   {{- end -}}
   ```

2. **Trim whitespace** with `-`:
   ```go
   {{- if .condition -}}
   Content without extra newlines
   {{- end -}}
   ```

3. **Use `output` for dynamic values**:
   ```go
   {{ output "git" "config" "user.name" | trim }}
   ```

4. **Validate with prompts**:
   ```go
   {{- $choice := promptChoice "Question?" (list "Yes" "No") -}}
   {{- $environmentTags := promptMultichoice "Select tags" (list "core" "dev" "work") -}}
   ```

5. **Comment templates**:
   ```go
   {{- /* This is a comment that won't appear in output */ -}}
   ```

### Script Best Practices

1. **Always source utilities**:
   ```bash
   #!/bin/bash
   source "$HOME/.local/share/chezmoi/home/.scripts/utils.sh"
   set -euo pipefail
   ```

2. **Use strict error handling**:
   ```bash
   set -e   # Exit on error
   set -u   # Exit on undefined variable
   set -o pipefail  # Exit on pipe failure

   # Combined
   set -euo pipefail
   ```

3. **Validate inputs with loops**:
   ```bash
   while true; do
     printf "Enter value: "
     read -r input

     if validate "$input"; then
       break
     else
       warning "Invalid input, try again"
     fi
   done
   ```

4. **Package manager detection pattern**:
   ```bash
   local pkg_manager=""
   if command -v apt &> /dev/null; then
     pkg_manager="apt"
   elif command -v dnf &> /dev/null; then
     pkg_manager="dnf"
   elif command -v pacman &> /dev/null; then
     pkg_manager="pacman"
   fi

   case "$pkg_manager" in
     apt)
       # Debian/Ubuntu commands
       ;;
     dnf)
       # Fedora/RHEL commands
       ;;
     pacman)
       # Arch Linux commands
       ;;
     *)
       error "No supported package manager found"
       exit 1
       ;;
   esac
   ```

5. **Cleanup on exit**:
   ```bash
   TEMP_DIR=$(mktemp -d)
   trap 'rm -rf "$TEMP_DIR"' EXIT

   # Do work with TEMP_DIR
   # Cleanup happens automatically on script exit
   ```

6. **Check before install**:
   ```bash
   if command -v tool &> /dev/null; then
     info "Tool already installed, skipping"
     exit 0
   fi
   ```

### Configuration Hierarchy

1. **Base configuration**: Regular files (`.bashrc`, `.zshrc`)
2. **Shared configuration**: Template files sourced by multiple shells (`.sh_aliases.tmpl`, `.sh_functions.tmpl`)
3. **Host-specific**: Template conditionals based on `.chezmoi.hostname`
4. **OS-specific**: Conditionals based on `.chezmoi.os` or `.OS_id`
5. **Tag-specific**: Conditionals based on `.environmentTags` list
6. **Private settings**: `private_*` files with Bitwarden integration

---

## 🧪 Testing & Validation

### Pre-commit Checks

```bash
# Validate script syntax
shellcheck home/**/*.sh

# Test template rendering
chezmoi execute-template < home/.chezmoi.yaml.tmpl

# Dry-run apply
chezmoi apply --dry-run --verbose

# Check diff
chezmoi diff
```

### Common Testing Commands

```bash
# Re-run scripts (clears script state)
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply

# Verify template variables
chezmoi data

# Test specific file rendering
chezmoi cat ~/.bashrc

# Debug mode
chezmoi apply --verbose --debug

# Verify external sources
chezmoi verify

# List managed files
chezmoi managed

# Show source file for a target
chezmoi source-path ~/.bashrc
```

### Testing New Scripts

1. **Test script syntax**:
   ```bash
   bash -n home/.chezmoiscripts/linux/script.sh.tmpl
   shellcheck home/.chezmoiscripts/linux/script.sh.tmpl
   ```

2. **Test template rendering**:
   ```bash
   chezmoi execute-template < home/.chezmoiscripts/linux/script.sh.tmpl
   ```

3. **Dry-run specific script**:
   ```bash
   chezmoi state delete-bucket --bucket=scriptState
   chezmoi apply --dry-run
   ```

4. **Run in isolation**:
   ```bash
   # Render and save to temp file
   chezmoi execute-template < script.sh.tmpl > /tmp/test.sh
   bash -x /tmp/test.sh  # Debug mode
   ```

---

## 🔒 Security Considerations

### Bitwarden Integration

**Retrieving secrets**:
```go
{{- /* Retrieve entire item */ -}}
{{ bitwarden "item" "ITEM_NAME" }}

{{- /* Retrieve specific field */ -}}
{{ bitwarden "fields" "ITEM_NAME" "FIELD_NAME" }}

{{- /* Retrieve password */ -}}
{{ bitwarden "password" "ITEM_NAME" }}

{{- /* Retrieve username */ -}}
{{ bitwarden "username" "ITEM_NAME" }}
```

**Example usage**:
```go
[user]
  name = {{ .name }}
  email = {{ .email }}
{{- if .private }}
  signingkey = {{ bitwarden "fields" "GitHub GPG Key" "key_id" }}
{{- end }}
```

### Never Hardcode

**Sensitive data that MUST be in Bitwarden**:
- Passwords
- API tokens
- OAuth credentials
- SSH private keys
- Email credentials
- GPG keys
- Database connection strings

### File Permissions

**Use `private_` prefix** for sensitive files:
- `private_dot_gitconfig.tmpl` (may contain tokens)
- `private_dot_ssh/id_*` (SSH private keys)
- `private_dot_npmrc` (npm tokens)

**Chezmoi sets permissions automatically**:
- `private_*` files → `0600` (owner read/write only)
- Regular files → `0644` (owner read/write, others read)
- `executable_*` files → `0755` (executable)

### Script Security Patterns

1. **Validate URLs** before downloading:
   ```bash
   URL="https://example.com/file.zip"
   if echo "$URL" | grep -E -q '^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$'; then
     # Valid URL
     wget "$URL"
   else
     error "Invalid URL format"
     exit 1
   fi
   ```

2. **Verify checksums**:
   ```bash
   EXPECTED_SHA="abc123..."
   DOWNLOADED_SHA=$(sha256sum file.zip | cut -d' ' -f1)

   if [ "$DOWNLOADED_SHA" != "$EXPECTED_SHA" ]; then
     error "Checksum mismatch!"
     error "Expected: $EXPECTED_SHA"
     error "Got: $DOWNLOADED_SHA"
     exit 1
   fi
   ```

3. **Use secure permissions**:
   ```bash
   umask 077  # Strict permissions for new files (0700 for dirs, 0600 for files)

   chmod 600 sensitive_file
   chmod 700 sensitive_dir
   chown root:root /usr/local/bin/tool
   chmod 755 /usr/local/bin/tool
   ```

4. **Clear sensitive variables immediately**:
   ```bash
   PASSWORD="secret"
   # Use password immediately
   some_command "$PASSWORD"
   # Clear from memory
   PASSWORD=""
   unset PASSWORD
   ```

5. **Avoid storing credentials in variables** (use interactive prompts):
   ```bash
   # BAD: Credentials visible in process list
   bw login "$EMAIL" "$PASSWORD"

   # GOOD: Interactive prompts (credentials hidden)
   bw login --raw
   ```

6. **Validate file ownership**:
   ```bash
   if [ "$(stat -c '%U:%G' /path/to/file)" != "root:root" ]; then
     error "File has incorrect ownership"
     exit 1
   fi
   ```

---

## 🖥️ Platform-Specific Guidance

### Linux Distribution Support

**Debian/Ubuntu** (apt/apt-get):
```bash
# Update package list
sudo apt update

# Install packages
sudo apt install -y package1 package2

# Full upgrade
sudo apt full-upgrade

# Remove unnecessary packages
sudo apt autoremove

# Clean cache
sudo apt clean && sudo apt autoclean
```

**Fedora/RHEL/CentOS** (dnf):
```bash
# Check for updates
sudo dnf check-update

# Install packages
sudo dnf install -y package1 package2

# Upgrade all packages
sudo dnf upgrade

# Remove unnecessary packages
sudo dnf autoremove

# Clean cache
sudo dnf clean all
```

**Arch Linux/Manjaro** (pacman):
```bash
# Sync databases and upgrade
sudo pacman -Syu

# Install packages
sudo pacman -S --noconfirm package1 package2

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null || true

# Clean cache
sudo pacman -Sc --noconfirm
```

### WSL-Specific Patterns

**Detection in templates**:
```go
{{- if .is_WSL -}}
# WSL-specific configuration
{{- end -}}
```

**Detection logic** (in `.chezmoi.yaml.tmpl`):
```go
{{- $is_WSL := false -}}
{{- if eq .chezmoi.os "linux" -}}
{{-   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") -}}
{{-     $is_WSL = true -}}
{{-   end -}}
{{- end -}}
```

**Common WSL aliases**:
```bash
{{- if .is_WSL }}
# Use Windows SSH agent
alias ssh-add='ssh-add.exe'

# Clipboard integration
alias clip='clip.exe'
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'

# Windows explorer
alias explorer='explorer.exe'
alias open='explorer.exe'

# Open current directory in Windows explorer
alias here='explorer.exe .'
{{- end }}
```

### Tag-Based Installation

```bash
{{- if has "core" .environmentTags }}
# Base essentials
packages="git vim curl wget unzip zip"
{{- end }}

{{- if has "core+" .environmentTags }}
# Enhanced tools
packages="$packages eza bat fd-find ripgrep"
# yazi (file manager)
# fastfetch (system info)
{{- end }}

{{- if has "dev" .environmentTags }}
# Development tools
packages="$packages build-essential nodejs npm python3 python3-pip"
# docker, docker-compose
{{- end }}

{{- if has "sysAdmin" .environmentTags }}
# System administration
packages="$packages htop ncdu tmux net-tools"
{{- end }}

{{- if has "devOps" .environmentTags }}
# DevOps tools
# kubectl, helm, terraform, ansible
{{- end }}
```

---

## 📚 Quick Reference

### Chezmoi Commands

```bash
# Initialization
chezmoi init <repo>              # Initialize from repository
chezmoi init <repo> --apply      # Init + apply
chezmoi init <repo> --one-shot   # Init + apply + cleanup

# Daily usage
chezmoi apply                    # Apply changes to home directory
chezmoi diff                     # Show differences
chezmoi update                   # Pull from git + apply
chezmoi status                   # Show status

# Editing
chezmoi edit <file>              # Edit source file
chezmoi add <file>               # Add file to source
chezmoi cd                       # Change to source directory

# Information
chezmoi data                     # Show template data
chezmoi managed                  # List managed files
chezmoi source-path <file>       # Show source file for target
chezmoi target-path <file>       # Show target path for source

# Template testing
chezmoi execute-template         # Test templates (stdin)
chezmoi cat <file>               # Show rendered file content

# Debugging
chezmoi apply --dry-run          # Preview changes
chezmoi apply --verbose          # Verbose output
chezmoi apply --debug            # Debug mode
chezmoi verify                   # Verify external sources

# Advanced
chezmoi state delete-bucket --bucket=scriptState  # Reset script state
chezmoi state dump               # Show internal state
chezmoi doctor                   # Check for issues
```

### Important Files

| File                                        | Purpose                                    |
| ------------------------------------------- | ------------------------------------------ |
| `install.sh`                                | Bootstrap installation script              |
| `.chezmoi.yaml.tmpl`                        | Main configuration with prompts            |
| `.chezmoiexternal.yaml.tmpl`                | External dependencies (oh-my-zsh, plugins) |
| `.chezmoiignore`                            | Conditional ignore patterns                |
| `.chezmoihooks/install-password-manager.sh` | Install Bitwarden CLI                      |
| `.scripts/utils.sh`                         | Shared utility functions                   |
| `dot_bashrc`                                | Bash shell configuration                   |
| `dot_zshrc`                                 | Zsh shell configuration                    |
| `dot_sh_aliases.tmpl`                       | Shell aliases (bash + zsh)                 |
| `dot_sh_functions.tmpl`                     | Shell functions (bash + zsh)               |
| `dot_config/fastfetch/config.jsonc`         | System info display                        |
| `dot_config/yazi/yazi.toml`                 | File manager config                        |
| `private_dot_gitconfig.tmpl`                | Git configuration                          |
| `dot_ssh/config`                            | SSH host configuration                     |

### Variables Reference

```go
# User information
{{ .name }}                      # User name (phenates)
{{ .email }}                     # Email address (phen4tes@gmail.com)

# Configuration flags
{{ .private }}                   # Private mode (bool)
{{ .installZSH }}                # Install ZSH (bool)
{{ .changeShell }}               # Change default shell (bool)

# Lists
{{ .environmentTags }}           # Machine environment tags (list)
{{ .secretsTags }}                   # SSH keys to install (list)

# System information
{{ .OS_id }}                     # OS identifier (e.g., linux-debian)
{{ .is_WSL }}                    # WSL detection (bool)

# Chezmoi built-ins
{{ .chezmoi.os }}                # OS (linux/darwin/windows)
{{ .chezmoi.arch }}              # Architecture (amd64/arm64)
{{ .chezmoi.hostname }}          # Hostname
{{ .chezmoi.username }}          # Current user
{{ .chezmoi.homeDir }}           # Home directory
{{ .chezmoi.osRelease.id }}      # Distribution ID (debian/fedora/arch)
{{ .chezmoi.kernel.osrelease }}  # Kernel release (for WSL detection)

# Template functions
{{ has "value" .list }}          # Check if list contains value
{{ lookPath "command" }}         # Check if command exists in PATH
{{ output "cmd" "arg" }}         # Execute command and get output
{{ bitwarden "type" "item" }}    # Retrieve from Bitwarden
{{ gitHubLatestReleaseAssetURL "owner/repo" "pattern" }}  # Get GitHub release URL
```

### Common Template Patterns

```go
# Conditional inclusion
{{- if .condition -}}
content
{{- end -}}

# Multi-condition
{{- if and .private (has "work" .environmentTags) -}}
content
{{- end -}}

# OS detection
{{- if eq .chezmoi.os "linux" -}}
content
{{- end -}}

# Tag check
{{- if has "dev" .environmentTags -}}
content
{{- end -}}

# Command availability
{{- if lookPath "docker" -}}
content
{{- end -}}

# Whitespace control (trim)
{{- /* Comment */ -}}
{{- .variable -}}
```

---

**Last Updated**: 2025-10-30
**Chezmoi Version**: Latest
**Repository**: https://github.com/phenates/dotfiles
**Author**: phenates
