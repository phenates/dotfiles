# dotfiles

[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)](https://www.chezmoi.io/)
[![GitHub last commit](https://img.shields.io/github/last-commit/phenates/dotfiles)](https://github.com/phenates/dotfiles/commits)

My dotfiles management with [chezmoi](https://www.chezmoi.io).

## Table of Contents

1. [Project Overview](#project-overview)
2. [Cheat-sheet](#cheat-sheet-chezmoi)
3. [Installation & Initialization Flow](#installation--initialization-flow)
4. [Key features](#key-features)
5. [Architecture & Key Components](#architecture--key-components)
6. [Template System](#template-system)
7. [Scripts & Hooks](#scripts--hooks)
8. [Development Workflows](#development-workflows)
9.  [Testing & Validation](#testing--validation)
10. [Documentation References](#documentation-references)

## Project Overview

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io), designed to manage, bootstrap and maintain differents environments (core, development, system administration,...) across different OS/Distribution (Linux, Windows) and/or machines. The repository contains configuration files, scripts, and automation for this purpose.

Mains features:

- **OS detection**: Linux, Windows Subsystem for Linux, Windows and applying specific configurations
- **Private mode**: Password manager (Bitwarden CLI) integration for secrets management.
- **Tag-based configuration**: 
    - Type of environments: core, core+, ...
    - Secrets to populates: select secrets whos will be used, SSH_key, Tokens,...
- **Multi-shell configuration**: Bash, Zsh, Powershell

## Cheat-sheet Chezmoi

```bash
# Initialization
chezmoi init <repo>              # Initialize from repository
chezmoi init <repo> --apply      # Init + apply
chezmoi init <repo> --one-shot   # Init + apply + cleanup
  
# Daily usage
chezmoi apply                    # Apply changes to home directory
chezmoi diff                     # Show differences
chezmoi update                   # Pull from git + apply
chezmoi status                   # Show status
  
# Editing
chezmoi edit <file>              # Edit source file
chezmoi add <file>               # Add file to source
chezmoi cd                       # Change to source directory
  
# Information
chezmoi data                     # Show template data
chezmoi managed                  # List managed files
chezmoi source-path <file>       # Show source file for target
chezmoi target-path <file>       # Show target path for source
  
# Template testing
chezmoi execute-template         # Test templates (stdin)
chezmoi cat <file>               # Show rendered file content
  
# Debugging
chezmoi apply --dry-run          # Preview changes
chezmoi apply --verbose          # Verbose output
chezmoi apply --debug            # Debug mode
chezmoi verify                   # Verify external sources
  
# Advanced
chezmoi state delete-bucket --bucket=scriptState  # Reset script state
chezmoi state dump               # Show internal state
chezmoi doctor                   # Check for issues
```

## Installation & Initialization Flow

### Linux

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
# or if redirect URL exists
sh -c "$(curl -fsLS https://xxxx-linux.MyDomain.com/)"
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/phenates/dotfiles/master/install.ps1 | iex
# or if redirect URL exists
irm https://xxxx-windows.MyDomain.com/ | iex
```

**Note**: If you encounter execution policy errors, you can bypass it for the installation:

```powershell
Set-ExecutionPolicy -Scope CurrentUser Unrestricted
# Then run the installation command again
```

### Initialization Flow

1. **Install chezmoi binary**
   1. Run install commands (see [Installation](#-installation)) corresponding to `install.sh` script for Linux and `install.ps1` for Windows, that installing chezmoi binary (Linux: `~/.local/bin/chezmoi`, Windows: `$HOME\bin\chezmoi.exe`)
   2. Choose witch chezmoi command to execute next or quit

2. **Chezmoi init with interactive prompts:** chezmoi host configuration
   - Private mode: enable or not the private mode (install password manager and populate secrets (see ???))
   - Environments tags: select environment tags (conditionning dotfiles application and packages installations)
   - Secrets tags: If Private mode enable, select witch secrets will be populated

3. **Execute hooks (hooks.read-source-state.pre):** If Private mode enable, installing password manager

4. **Run before scripts:** packages installation, shell configure, ...

5. **Apply dotfiles** to home directory

6. **Run after scripts**

## Key features

### Environment Tags

**Environment tags** provide a flexible system for deploying different sets of configuration files, packages installation and external files based on the role or purpose of a machine.
This allows to maintain a single dotfiles repository while supporting different machine configurations (minimal server, developer workstation, AI development machine, etc.).

#### Environment Tags Diagram

```
  ┌─────────────────────┐
  │    User Prompt      │
  │   (chezmoi init)    │
  └──────────┬──────────┘
             │
             ├─> Select environments tags for this machine? ([x] core; [ ] core+; ...)
             |
             ▼
┌─────────────────────────────────────────────┐
│        Template Processing/Rendering        |
|              (chezmoi apply)                │
| Templates access tags via: .environmentTags |             
└────────────────────────┬────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
┌────────────────┐ ┌────────────────┐ ┌──────────────────────┐
│ 3A. PACKAGE    │ │ 3B. FILE       │ │ 3C. EXTERNAL         │
│ INSTALLATION   │ │ FILTERING      │ │ DOWNLOADS            │
│                │ │                │ │                      │
│ .scripts       │ │ .chezmoiignore │ │ .chezmoiexternal     │
│ - Lookup pkgs  │ │ evaluates      │ │ downloads binaries   │
│ - Install      │ │ conditions     │ │ if tag matches       │
│                │ │                │ │                      │
└────────────────┘ └────────────────┘ └──────────────────────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                  Applied Environmant                         │
│                                                              │
│  Packages installed: curl, wget, git, eza, file, 7zip, ...   │
│  Files deployed: Only those not ignored by .chezmoiignore    │
│  Binaries available: ~/.local/bin/yazi, ~/.local/bin/ya      │
└──────────────────────────────────────────────────────────────┘
```

#### How Environment Works

| File                                            | Purpose                                         |
| ----------------------------------------------- | ----------------------------------------------- |
| `home/.chezmoi.yaml.tmpl`                       | Main configuration template (prompts, settings) |
| `home/.chezmoidata.yaml`                        | Package database                                |
| `home/.chezmoiignore.tmpl`                      | Files to ignore based on tags                   |
| `home/dot_local/bin/.chezmoiexternal.yaml.tmpl` | External binaries to download                   |

#### Adding a New Environment

1. **Define the tag in `.chezmoidata.yaml`**:
   ```yaml
   packages:
     linux:
       apt:
         dev:  # ← New tag
           - gcc
           - make
           - cmake
     windows:
       winget:
         dev:  # ← New tag
           - Microsoft.VisualStudio.2022.Community
   ```

2. **Add to available choices in `.chezmoi.yaml.tmpl`**:
   ```go
   {{- $tag_choices := list "core" "core+" "dev" -}}
   ```

3. **(Optional) Add conditional file rules in `.chezmoiignore.tmpl`**:
   ```go
   {{ if not (has "dev" .environmentTags) }}
   .config/vscode
   {{ end }}
   ```

4. **Reinitialize chezmoi**:
   ```bash
   chezmoi init --force
   ```

### Private mode and Secrets management

**Private mode** enables secure management of sensitive dotfiles (SSH keys, API tokens, credentials) with [Bitwarden](https://bitwarden.com/) as a secrets vault. When enabled, chezmoi templates can fetch secrets from your Bitwarden vault at apply time, ensuring that **no sensitive data is ever stored in the repository**.

**Security Considerations**, sensitive data (secrets) MUST be in Bitwarden, Never Hardcode

#### Private mode Diagram

```
┌─────────────────────┐
│     User Promp      │
│   (chezmoi init)    │
└──────────┬──────────┘
           │
           ├─> Enable Private mode? [Yes/No]
           |─> Select Secrets tags? [id_homelab/id_github/id_phenates]
           │
           ▼
┌─────────────────────────────────┐
│    install-password-manager     │
│         (chezmoi hook)          │
│  - Downloads Bitwarden CLI      │
│  - Prompts for BW server URL &  |
|    login                        │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│  Template Processing/Rendering  │
│         (chezmoi apply)         │
│  - Fetches secrets from BW      │
│  - Populates templates          │
│  - Applies file permissions     │
└──────────┬──────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│       Applied Secrets           │
│  ~/.gitconfig (with token)      │
│  ~/.ssh/id_* (keys)             │
└─────────────────────────────────┘
```

#### How Private Mode Works

| File                                          | Purpose                                         |
| --------------------------------------------- | ----------------------------------------------- |
| `home/.chezmoi.yaml.tmpl`                     | Main configuration template (prompts, settings) |
| `home/.chezmoiignore.tmpl`                    | Files to ignore based on secrets tags           |
| `home/.chezmoihooks/install-password-manager` | Password manager installation script            |
| `home/dot_ssh/private_id_*.tmpl`              | Dotfile with secrets settlement exemple         |
| `home/private_dot_gitconfig.tmpl`             | Git config with GitHub token                    |

- **Configuration File**

Private mode is configured in chezmoi config file `home/.chezmoi.yaml.tmpl` and generate two user prompts during chezmoi init:

  - Enable Private mode: [Yes/No] to enable the mode

```go
{{- /* Default values */ -}}
{{- $private  := false -}} {{/* true if this machine should have private secrets */}}

{{- /* Interactive prompt during chezmoi init */ -}}
{{- $private_choices := list "Yes" "no" -}}
{{- $private  := promptChoice "  ?  Enable Private mode on this machine (install bitwarden_cli and populate secrets) ?" $private_choices $privateDefault -}}
{{- if eq $private "Yes" -}}
{{-   $private = true -}}
{{- else -}}
{{-   $private = false -}}
{{- end -}}

data:
  private: {{ $private }}
```

  - Select Secrets tags: [Multichoice] to select wich secrets should be populate, if Private mode enable

```go
{{- if $private -}}
{{-   $secretsTags_choices := list "SSH_id_xxxx" "Token_yyyy" "Password_zzzz" -}}
{{-   $secretsTags = promptMultichoice "  ?  Select secrets tags to populate on this machine (e.g., id_github, ... )" $secretsTags_choices $previousSecretsTags -}}
{{-   writeToStdout (printf "    ➜ '%s' \n\n" $secretsTags ) -}}
{{- end -}}
```

- **Password Manager Installation**

If Private mode is enable, the chezmoi hook (read-source-state) will run `.chezmoihooks/install-password-manager` script to install Bitwarden CLI and prompt for configures the Bitwarden server URL and login to your Bitwarden vault.

- **Conditional File Inclusion**

Private mode affects which files get applied via [home/.chezmoiignore.tmpl](home/.chezmoiignore.tmpl):

```shell
{{- if not .private }}
# Ignore ALL ssh files if not in private mode
.ssh/**
{{- else }}
# In private mode, only ignore specific SSH keys based on secretsTags
{{-   if not (has "SSH_id_xxxx" .secretsTags) }}
.ssh/id_xxxx*
.ssh/authorized_keys
{{-   end }}
{{-   if not (has "Token_yyyy" .secretsTags) }}
App/Token_yyyy*
{{-   end }}
{{- end }}
```

- **Secrets Settlement**

Chezmoi will fetch secrets from Bitwarden and populate your dotfiles templates
File: `home/dot_ssh/private_id_xxxx.tmpl`

```go
{{- if .private -}}
{{-     (bitwarden "item" "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx").sshKey.privateKey -}}
{{- end -}}
```

#### Adding New Secrets

1. Create a new Bitwarden item
2. Copy the item UUID
3. Create a new template file (e.g., `private_dot_app-xxx_token.tmpl`)
4. Add template logic:
   ```go
   {{- if .private -}}
   {{-     (bitwardenFields "item" "NEW-UUID").tokenField.value -}}
   {{- end -}}
   ```
5. Modifi `home/.chezmoi.yaml.tmpl` to add new tag in secretsTags_choices list   
6. Configure .chezmoiigore for conditional file inclusion:
   ```go
   {{-   if not (has "Token_yyyy" .secretsTags) }}
   .app-xxx_token
   {{-   end }}
   ```

#### File Permissions

**Use `private_` prefix** for sensitive files → `0600` (owner read/write only)

#### Bitwarden Template Functions

```go
{{/* Returns the full Bitwarden item object */}}
{{ bitwarden "item" "UUID" }}

{{/* Returns the value of a custom field named 'fieldName' */}}
{{ (bitwardenFields "item" "UUID").fieldName.value }}

{{/* Returns key from Bitwarden SSH Key item */}}
{{ (bitwarden "item" "UUID").sshKey.privateKey }}
{{ (bitwarden "item" "UUID").sshKey.publicKey }}
```

#### Bitwarden CLI Commands

```bash
# Login to Bitwarden (creates session)
bw login

# Lock vault (requires master password to unlock)
bw lock

# Unlock vault (stores session key)
bw unlock

# Set session key in environment (for automation)
export BW_SESSION="session_key_here"

# List items
bw list items  --pretty

# Get specific item
bw get item [UUID|itemName] --pretty

# Edit item
bw edit item <UUID>
```

#### gitconfig Special case

A special case is used for the `home/private_dot_gitconfig.tmpl` file, which is not associated with a Secret tag and will automaticly appliqued if Private mode is enable.

To simplify git operations (fetch, push) without to enter manualy credidentials, the github remote URL use repository token access, stored in a Bitwarden item.

Based on the Git insteadOf directive, a template will automatically insert the directive with the token access into the user Git config file.

```go
{{/* Private mode: change the remote URL to use token authentication URL for github dotfiles repo */}}
{{ if .private }}
# Private mode: use token auth URL for github dotfiles repo
[url "https://<Github_User>:{{ (bitwardenFields "item" "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx").githubDotfilesToken.value }}@github.com/<Github_User>/dotfiles.git"]
        insteadOf = https://github.com/<Github_User>/dotfiles.git
        pushInsteadOf = https://github.com/<Github_User>/dotfiles.git
{{ end }}
```

#### References

- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [chezmoi Bitwarden Integration](https://www.chezmoi.io/user-guide/password-managers/bitwarden/)
- [GitHub Fine Grained Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)

## Architecture & Key Components

### Directory Structure

```shell

dotfiles/

├── install.sh                           # Bootstrap installation script for Linux/macOS
├── install.ps1                          # Bootstrap installation script for Windows
├── .chezmoiroot                         # Chezmoi source directory declaration, source state dir read from this file
├── .chezmoiversion                      # Defining the minimum version of chezmoi required
├── home/                                # Chezmoi source directory (see .chezmoiroot)
│   ├── .chezmoi.yaml.tmpl               # Main configuration with prompts
│   ├── .chezmoiexternal.yaml.tmpl       # List of external ressources to be included, can exist in multiple dir level
│   ├── .chezmoiignore                   # Conditional ignore patterns, can exist in multiple dir level
│   ├── .chezmoihooks/                   # Pre/post hooks
│   │   ├── install-password-manager.sh
│   │   └── ...
│   ├── .chezmoiscripts/linux/          # Installation scripts
│   │   ├── run_onchange_before_10_install-packages.sh.tmpl
│   │   └── ...
│   ├── .utils/                         # Shared utilities
│   │   ├── utils.sh                    # Bash utilities
│   │   └── utils.ps1                   # PowerShell utilities
│   ├── dot_xxxx                        # Configuration/dotfile file managed by chezmoi 
│   ├── dot_xxx_yyyy.tmpl               # Configuration/dotfile file managed by chezmoi, using templating
│   ├── private_dot_gitconfig.tmpl      # Configuration/dotfile file managed by chezmoi, using templating (private)
│   ├── dot_config/                     # XDG config directory managed by chezmoi
│   │   ├── xxxDir/config.jsonc
│   │   └── ...
│   ├── dot_local/                      # User-local files managed by chezmoi
│   │   ├── bin/.chezmoiexternal.yaml.tmpl    # Binary downloads
│   │   └── share/.chezmoiexternal.yaml.tmpl  # Fonts, themes
.   .
.   .
.
```

### Template Variables

Defined in `.chezmoi.yaml.tmpl`:

| Variable                | Type   | Description              | Example                       |
| ----------------------- | ------ | ------------------------ | ----------------------------- |
| `.private`              | bool   | Private mode flag        | `true`/`false`                |
| `.environmentTags`      | list   | Machine environment tags | `["core", "dev"]`             |
| `.secretsTags`          | list   | Secrets to populate      | `["id_github", "id_homelab"]` |
| `.installZSH`           | bool   | Install ZSH              | `true`/`false`                |
| `.changeShell`          | bool   | Change default shell     | `true`/`false`                |
| `.OS_id`                | string | OS identifier            | `linux-debian`                |
| `.is_WSL`               | bool   | WSL detection            | `true`/`false`                |
| `.chezmoi.os`           | string | Operating system         | `linux`/`darwin`              |
| `.chezmoi.arch`         | string | Architecture             | `amd64`/`arm64`               |
| `.chezmoi.hostname`     | string | Hostname                 | `myserver`                    |
| `.chezmoi.username`     | string | Current user             | `phenates`                    |
| `.chezmoi.osRelease.id` | string | Distribution ID          | `debian`/`fedora`             |

### File Naming Conventions

#### Chezmoi Prefixes

| Prefix          | Purpose            | Example                         | Target                |
| --------------- | ------------------ | ------------------------------- | --------------------- |
| `dot_`          | Regular dotfiles   | `dot_bashrc`                    | `~/.bashrc`           |
| `private_`      | Sensitive dotfiles | `private_dot_gitconfig.tmpl`    | `~/.gitconfig`        |
| `executable_`   | Executable files   | `executable_script.sh`          | Executable script     |
| `run_once_`     | Run once scripts   | `run_once_install.sh`           | One-time execution    |
| `run_onchange_` | Run on change      | `run_onchange_packages.sh.tmpl` | When template changes |
| `.tmpl`         | Template files     | `dot_sh_aliases.tmpl`           | Dynamic content       |

#### File Permissions

Chezmoi sets permissions automatically:

- `private_*` files → `0600` (owner read/write only)
- Regular files → `0644` (owner read/write, others read)
- `executable_*` files → `0755` (executable)

## Template System

### Template Files

Files with `.tmpl` extension use chezmoi's templating (Go template syntax) :

```go
{{- if .private -}}
# Private mode enabled - load secrets from Bitwarden
{{ bitwarden "item" "GitHub Token" }}
{{- end }}
  

{{- if has "dev" .tags -}}
# Development tools enabled and installation
export PATH="$HOME/.local/bin:$PATH"
{{- end }}
```

### Conditional Logic Patterns

**OS Detection**:

```shell
{{- if eq .chezmoi.os "linux" -}}
# Linux-specific configuration
{{- else if eq .chezmoi.os "windows" -}}
# Windows-specific configuration
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
{{- if has "core+" .tags -}}
# Install enhanced tools like yazi
{{- end -}}
```

**Multi-condition**:

```go
{{- if and .private (has "work" .tags) -}}
# Work-specific private configuration
{{- end -}}
```

### External Sources

Template for downloading binaries/archives in `.chezmoiexternal.yaml.tmpl`:

```yaml
".local/bin/tool":
  type: "archive-file"  # or "file"
  url: "{{ gitHubLatestReleaseAssetURL "owner/repo" "pattern" }}"
  executable: true
  refreshPeriod: "168h"  # 1 week
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

### Template functions

```go
{{ has "value" .list }}          # Check if list contains value
{{ lookPath "command" }}         # Check if command exists in PATH
{{ output "cmd" "arg" }}         # Execute command and get output
{{ bitwarden "type" "item" }}    # Retrieve from Bitwarden
{{ gitHubLatestReleaseAssetURL "owner/repo" "pattern" }}  # Get GitHub release URL
```

## Scripts & Hooks

### Shared Utilities

The `.utils` directory contains utility functions for both Bash and PowerShell scripts.

- Bash Utilities (`home/.utils/utils.sh`)

**Usage**:

```bash
# Always source at the beginning of scripts
source "$HOME/.local/share/chezmoi/home/.utils/utils.sh"

# Example usage
step "Installing packages..."
if command_exists apt; then
  success "APT package manager found"
else
  error "APT not found"
  exit 1
fi
```

- PowerShell Utilities (`home/.utils/utils.ps1`)

**Usage**:

```powershell
# Import at the beginning of scripts
. "$HOME\.local\share\chezmoi\home\.utils\utils.ps1"

# Example usage
Write-Step "Installing packages..."
if (Test-CommandExists "winget") {
    Write-Success "Winget found"
} else {
    Write-Error "Winget not found"
    exit 1
}
```

### Hook Types

**`hooks.read-source-state.pre`** - Before reading source state

- **Example**: `install-password-manager.sh` (install Bitwarden CLI)
- **Purpose**: Install dependencies needed for template rendering

## Development Workflows

### Making Changes on dotfiles

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
chezmoi apply --dry-run    # Test first
chezmoi apply              # Actually apply
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
chezmoi update    # Pulls from git + applies
```

### Adding New Ressources

1. **Add new config file/dotfile** in `home/dot_config/tool/`

```bash
# Add the file to chezmoi managed ressources
chezmoi add .config/tool/config.yml

# Create directly in the chezmoi source dir
mkdir -p home/dot_config/tool
touch home/dot_config/tool/config.yml
```

2. **Add external sources to `home/dot_local/bin/.chezmoiexternal.yaml.tmpl`

```yaml
# See external Sources
".local/bin/tool":
     type: "file"
     url: "https://example.com/tool-binary"
     executable: true
```

3. **Update `.chezmoiignore`** if conditional

```shell
{{ if not (has "dev" .tags) }}
.config/tool/
{{ end }}
```

4. **Add installation script** in `.chezmoiscripts/linux/`

```bash
# run_onchange_before_20_install-tool.sh.tmpl
{{ if has "dev" .tags -}}
# Install tool dependencies
{{ end -}}
```

5. **Update package lists** if needed

### Adding/Populate Secrets

1. **Store secrets** in Bitwarden vault

- Item name: `My_Secret_Name`
- Field: Store the secret content

1. **Add secret template**: 

```go
{{ bitwarden "item" "My_Secret_Name" }}
```

2. **Add field secret template**: `home/dot_ssh/id_NAME.pub.tmpl`

```go
{{ bitwarden "fields" "SSH_ID_NAME" "public_key" }}
```

3. **Update `.chezmoiignore`** conditional

```shell
{{ if not (has "id_NAME" .secretsTags) }}
.ssh/id_NAME
.ssh/id_NAME.pub
{{ end }}
```

4. **Add to selection prompts** in `.chezmoi.yaml.tmpl`

```go
{{- if $private -}}
{{-   $secretsTags_choices := list "id_xxx" "id_yyy" "id_NAME" -}}
{{-   $secretsTags = promptMultichoice "Select secrets tags to populate on this machine" $secretsTags_choices -}}
{{- end -}}
```

## Testing & Validation

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
bash -x /tmp/test.sh  # Debug mode
```

## Documentation References

- [chezmoi - documentation](https://www.chezmoi.io/)
- Examples/Inspirations:
    - [Doctor Documentation \| Install Doctor](https://install.doctor/docs)
    - [GitHub - twpayne/dotfiles: My dotfiles, managed with https://chezmoi.io.](https://github.com/twpayne/dotfiles)
    - [GitHub - cearley/dotfiles: My personal dotfiles and configuration for various tools and applications.](https://github.com/cearley/dotfiles)
    - [GitHub - nandalopes/dotfiles: YADR - The best vim, git, zsh plugins and the cleanest vimrc you've ever seen (GNU/Linux fork)](https://github.com/nandalopes/dotfiles)
