# dotfiles

[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)](https://www.chezmoi.io/)
[![GitHub last commit](https://img.shields.io/github/last-commit/phenates/dotfiles)](https://github.com/phenates/dotfiles/commits)

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io), targeting Linux (including WSL2) and Windows environments.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Installation](#installation)
3. [Chezmoi Cheat-sheet](#chezmoi-cheat-sheet)
4. [Initialization Flow](#initialization-flow)
5. [Key Features](#key-features)
6. [Architecture](#architecture)
7. [Template System](#template-system)
8. [Scripts Reference](#scripts-reference)
9. [Development Workflows](#development-workflows)
10. [References](#references)

---

## Project Overview

Single dotfiles repository managing configuration across Linux, WSL2 and Windows — without secrets or external password managers.

**What it manages:**

- **Packages** — apt (Linux) and winget + PowerShell modules (Windows), organized by environment tag
- **Shell** — zsh with oh-my-zsh, powerlevel10k, syntax highlighting, autosuggestions, fzf, zoxide
- **Terminal tools** — fastfetch, yazi (file manager), eza, bat, fd, ripgrep
- **WSL2 integration** — `/etc/wsl.conf` configuration, home symlinks (Windows drives, SSH keys), SSH agent bridge
- **Git** — `.gitconfig` template per OS
- **VS Code** — file associations for chezmoi template files

---

## Installation

### Linux / WSL2

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"

# or

sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/phenates/dotfiles/master/install.ps1 | iex
```

> If execution policy blocks the script:
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser Unrestricted
> ```

---

## Chezmoi Cheat-sheet

```bash
# ── Init ─────────────────────────────────────────────────────────────────────
chezmoi init phenates                # Clone repo, generate config
chezmoi init phenates --apply        # Clone + apply
chezmoi init phenates --one-shot     # Clone + apply + remove source dir
chezmoi init --force                 # Re-run init prompts (re-init)
chezmoi init --force --apply         # Re-init + apply immediately

# ── Daily ────────────────────────────────────────────────────────────────────
chezmoi apply                        # Apply source to home (autoCommit: true → auto git commit + push)
chezmoi apply --dry-run              # Preview without applying
chezmoi apply --verbose              # Show each file operation
chezmoi apply --debug                # Full debug output
chezmoi apply --exclude scripts      # Apply files only, skip scripts
chezmoi apply --include scripts      # Run scripts only, skip files
chezmoi apply --keep-going           # Continue on errors
chezmoi update                       # git pull + apply
chezmoi diff                         # Show pending changes (source vs target)
chezmoi diff ~/.zshrc                # Diff for a specific file
chezmoi status                       # File-level status (A/M/D)

# ── Source editing ────────────────────────────────────────────────────────────
chezmoi edit ~/.zshrc                # Open source file in $EDITOR
chezmoi edit --apply ~/.zshrc        # Edit + apply immediately
chezmoi add ~/.config/tool/conf      # Add file to source state
chezmoi re-add ~/.zshrc              # Update source from current target
chezmoi forget ~/.zshrc              # Remove from source (keeps target)
chezmoi remove ~/.zshrc              # Remove from source AND target
chezmoi cd                           # cd to source directory
chezmoi git -- status                # Run git in source directory
chezmoi git -- log --oneline -10     # Git log in source directory
chezmoi merge ~/.zshrc               # 3-way merge source/target/last-applied

# ── Inspection ────────────────────────────────────────────────────────────────
chezmoi data                         # All template variables (JSON)
chezmoi data | grep -i wsl           # Filter template variables
chezmoi dump-config                  # Show effective chezmoi config
chezmoi managed                      # List all managed files
chezmoi managed --include files      # List managed files only
chezmoi unmanaged                    # List unmanaged files in home
chezmoi cat ~/.zshrc                 # Show rendered file content
chezmoi source-path ~/.zshrc         # Source path for a given target
chezmoi target-path home/dot_zshrc  # Target path for a given source

# ── Templates ────────────────────────────────────────────────────────────────
chezmoi execute-template             # Render template from stdin
chezmoi execute-template '{{ .chezmoi.os }}'  # Render inline expression

# ── Externals ────────────────────────────────────────────────────────────────
chezmoi verify                       # Verify external sources checksums
chezmoi apply --refresh-externals    # Force re-download all externals

# ── State ────────────────────────────────────────────────────────────────────
chezmoi state dump                                        # Dump internal DB
chezmoi state delete-bucket --bucket scriptState          # Reset run_onchange_ state
chezmoi state delete-bucket --bucket entryState           # Reset run_once_ state

# ── Maintenance ──────────────────────────────────────────────────────────────
chezmoi upgrade                      # Upgrade chezmoi itself
chezmoi doctor                       # Check environment for issues
chezmoi purge                        # Remove chezmoi config + state (not dotfiles)
chezmoi archive --output=dotfiles.tar.gz  # Export source state as archive
chezmoi completion zsh               # Generate zsh completion script
```

---

## Initialization Flow

```
1. install.sh / install.ps1
   └── Downloads chezmoi binary → runs: chezmoi init --apply phenates

2. chezmoi init  (.chezmoi.yaml.tmpl evaluated)
   ├── Detects OS, distribution, WSL
   ├── On re-init from TTY: prompts for environment tags
   └── Generates ~/.config/chezmoi/chezmoi.yaml

3. chezmoi apply
   ├── run_onchange_before_00 → sudo: install, group membership, passwordless
   ├── run_onchange_before_10 → Packages installation (apt / winget)
   ├── run_onchange_before_20 → Python tools (uv install + uv tool install)
   ├── run_onchange_before_90 → chezmoi .deb installation (Linux)
   ├── External downloads     → oh-my-zsh, plugins, fonts, binaries (.chezmoiexternal.yaml.tmpl)
   ├── File application       → Dotfiles deployed to ~
   ├── run_onchange_after_20  → zsh as default shell + font cache
   ├── run_onchange_after_60  → /etc/wsl.conf configuration (WSL only)
   └── run_onchange_after_61  → Home symlinks: MaPomme, homelab, .ssh (WSL only)
```

---

## Key Features

### Environment Tags

Tags selected at `chezmoi init` time control which packages and tools are deployed.

| Tag    | Description                                                       |
| ------ | ----------------------------------------------------------------- |
| `core` | Base shell environment — all packages, zsh stack, yazi, fastfetch |

**Extending with a new tag:**

1. Add packages to `.chezmoidata.yaml`:

   ```yaml
   packages:
     linux:
       apt:
         dev:
           - gcc
           - make
   ```

2. Expose in `.chezmoi.yaml.tmpl`:

   ```go
   {{- $tag_choices := list "core" "dev" -}}
   ```

3. Optionally filter files in `.chezmoiignore.tmpl`:

   ```go
   {{ if not (has "dev" .environmentTags) }}
   .config/dev-tool/
   {{ end }}
   ```

4. Re-init: `chezmoi init --force`

---

### WSL2 Integration

Specific configuration applied automatically when `is_WSL` is `true`:

| Script                                          | Purpose                                                                              |
| ----------------------------------------------- | ------------------------------------------------------------------------------------ |
| `run_onchange_after_60_wsl-conf.sh.tmpl`        | Configures `/etc/wsl.conf`: default user, automount (`metadata,umask=077`), hostname |
| `run_onchange_after_61_wsl-simlinks.sh.tmpl`    | Creates home symlinks: `~/MaPomme → /mnt/e`, `~/homelab`, `~/.ssh → Windows .ssh`   |

**SSH agent** (`.zshrc.tmpl`, WSL only): starts a local `ssh-agent` and loads all private keys from `~/.ssh` (detected via `.pub` counterparts).

```bash
# On WSL startup: automatically loads all keys from ~/.ssh/*.pub
if [ -z "$SSH_AUTH_SOCK" ] && [[ -x /usr/bin/ssh-agent ]]; then
    eval "$(/usr/bin/ssh-agent -s)" > /dev/null
    for pub in ~/.ssh/*.pub; do
        key="${pub%.pub}"
        [[ -f "$key" ]] && /usr/bin/ssh-add "$key" 2>/dev/null
    done
fi
```

---

### Shell Stack (Linux / WSL2)

| Tool                      | How managed                                           |
| ------------------------- | ----------------------------------------------------- |
| `zsh`                     | apt package                                           |
| `oh-my-zsh`               | chezmoi external (archive, weekly refresh)            |
| `powerlevel10k`           | chezmoi external (pinned to latest GitHub release)    |
| `zsh-syntax-highlighting` | chezmoi external                                      |
| `zsh-autosuggestions`     | chezmoi external                                      |
| Meslo Nerd Font           | chezmoi external (archive)                            |
| `fastfetch`               | chezmoi external (binary, auto latest)                |
| `yazi` + `ya`             | chezmoi external (binary, auto latest)                |
| `fzf`                     | apt package + configured in `.zshrc`                  |
| `zoxide`                  | apt package + `eval "$(zoxide init zsh)"` in `.zshrc` |

---

## Architecture

### Directory Structure

```
dotfiles/
├── install.sh                              # Linux bootstrap
├── install.ps1                             # Windows bootstrap
├── .chezmoiroot                            # Source directory pointer
├── .chezmoiversion                         # Minimum chezmoi version
└── home/                                   # Chezmoi source root
    ├── .chezmoi.yaml.tmpl                  # Config generation + prompts
    ├── .chezmoidata.yaml                   # Package lists database
    ├── .chezmoiexternal.yaml.tmpl          # External downloads (plugins, fonts, binaries)
    ├── .chezmoiignore.tmpl                 # Conditional ignore rules
    ├── .utils/
    │   ├── utils.sh                        # Shared bash utilities (header/step/info/success...)
    │   └── utils.ps1                       # Shared PowerShell utilities
    ├── .chezmoiscripts/
    │   ├── linux/
    │   │   ├── run_onchange_before_00_sudo.sh.tmpl
    │   │   ├── run_onchange_before_10_os-install-packages.sh.tmpl
    │   │   ├── run_onchange_before_20_python-tools.sh.tmpl
    │   │   ├── run_onchange_before_90_chezmoi-package_install.sh.tmpl
    │   │   ├── run_onchange_after_20_shell-zsh.sh.tmpl
    │   │   ├── run_onchange_after_60_wsl-conf.sh.tmpl       # WSL only
    │   │   └── run_onchange_after_61_wsl-simlinks.sh.tmpl   # WSL only
    │   └── windows/
    │       └── run_onchange_before_10_install-packages.ps1.tmpl
    ├── dot_zshrc.tmpl
    ├── dot_bashrc
    ├── dot_nanorc
    ├── dot_sh_aliases.tmpl
    ├── dot_sh_functions.tmpl
    ├── private_dot_gitconfig.tmpl
    ├── dot_p10k.zsh
    └── dot_config/
        ├── fastfetch/                      # fastfetch configuration
        ├── ohmyposh/                       # Oh My Posh theme (Windows)
        └── yazi/
            ├── yazi.toml                   # Manager and preview settings
            └── keymap.toml                 # Custom keybindings + cheat sheet
```

### Template Variables

| Variable                | Type   | Description               | Example             |
| ----------------------- | ------ | ------------------------- | ------------------- |
| `.environmentTags`      | list   | Selected environment tags | `["core"]`          |
| `.OS_id`                | string | OS + distro identifier    | `linux-ubuntu`      |
| `.is_WSL`               | bool   | Running inside WSL2       | `true`              |
| `.chezmoi.os`           | string | Operating system          | `linux` / `windows` |
| `.chezmoi.arch`         | string | CPU architecture          | `amd64`             |
| `.chezmoi.username`     | string | Current user              | `phenates`          |
| `.chezmoi.hostname`     | string | Machine hostname          | `my-laptop`         |
| `.chezmoi.osRelease.id` | string | Linux distribution ID     | `ubuntu` / `debian` |

### File Naming Conventions

| Prefix / Suffix | Effect                             | Example                       |
| --------------- | ---------------------------------- | ----------------------------- |
| `dot_`          | Maps to dotfile                    | `dot_zshrc.tmpl` → `~/.zshrc` |
| `private_`      | Sets `0600` permissions            | `private_dot_gitconfig.tmpl`  |
| `executable_`   | Sets `0755` permissions            | `executable_script.sh`        |
| `run_once_`     | Runs once, never again             | `run_once_before_00_...`      |
| `run_onchange_` | Runs when template content changes | `run_onchange_before_10_...`  |
| `.tmpl`         | Go template processing             | `dot_zshrc.tmpl`              |

### Scripts Convention

Scripts follow a strict separation of concerns:

| Phase    | Prefix     | Role                                        |
| -------- | ---------- | ------------------------------------------- |
| `before_`| install    | Install packages, tools, binaries           |
| `after_` | configure  | Configure the system (shell, symlinks, sudo)|

**Rule:** everything that installs software goes in `before_`, everything that configures the system goes in `after_`. This guarantees all tools are present before any configuration script runs.

```
before_00  sudo configuration (install, group membership, passwordless)
before_10  apt / winget packages
before_20  Python tools (uv + uv tool install)
before_90  chezmoi .deb replacement
    ↓
    External downloads (.chezmoiexternal)
    File application (dotfiles)
    ↓
after_20   default shell, font cache
after_60   /etc/wsl.conf  (WSL only)
after_61   home symlinks  (WSL only)
```

### Package Database (`.chezmoidata.yaml`)

All package lists are centralized in `.chezmoidata.yaml`, organized by OS and package manager:

```yaml
packages:
  linux:
    apt:
      core: [zsh, git, ...]
  windows:
    winget:
      core: [Git.Git, ...]
  python:
    uv:
      core: [tldr, ...]
```

chezmoi reads this file and merges it into template data on **every `chezmoi apply`**.

> **No `chezmoi init` required.**
> Unlike the `data:` section of `chezmoi.yaml` — which is only regenerated on `chezmoi init` — `.chezmoidata.yaml` is a regular source file. Any change takes effect on the next `chezmoi apply`, which also re-triggers the relevant `run_onchange_` install script automatically.

---

## Template System

### OS / WSL Conditions

```go
{{- if eq .chezmoi.os "linux" -}}
# Linux-specific
{{- else if eq .chezmoi.os "windows" -}}
# Windows-specific
{{- end -}}

{{- if .is_WSL -}}
# WSL-only configuration
{{- end -}}
```

### Distribution Check

```go
{{- if eq .OS_id "linux-ubuntu" "linux-debian" -}}
# Debian/Ubuntu specific
{{- end -}}
```

### Environment Tag Check

```go
{{- if has "core" .environmentTags -}}
# Deploy core tools
{{- end -}}
```

### External Sources

```yaml
# In .chezmoiexternal.yaml.tmpl
".local/bin/tool":
    type: "archive-file"
    url: "{{ gitHubLatestReleaseAssetURL "owner/repo" "asset-pattern" }}"
    executable: true
    refreshPeriod: "168h"
    stripComponents: 1
    path: "bin/tool"
```

### Conditional Ignores (`.chezmoiignore.tmpl`)

Files or paths listed in `.chezmoiignore.tmpl` are excluded from chezmoi management. The file is a Go template, enabling OS- and WSL-conditional rules.

```go
# Ignore .ssh on WSL — managed as a symlink to Windows .ssh
# chezmoi must not touch it or the symlink would be replaced by a directory
{{ if .is_WSL }}
.ssh
.ssh/**
{{ end }}

# Ignore platform-specific directories
{{ if eq .chezmoi.os "windows" }}
.config/some-linux-tool/
{{ end }}
```

> **Rule:** any path that chezmoi should not own (symlinks, OS-specific dirs, externally managed files) must appear here, otherwise chezmoi will overwrite or track it.

### Useful Template Functions

```go
{{ has "value" .list }}                               # List contains value
{{ gitHubLatestRelease "owner/repo" }}                # Latest release info
{{ gitHubLatestReleaseAssetURL "owner/repo" "pat" }}  # Latest release asset URL
{{ lookPath "command" }}                              # Command in PATH?
{{ output "cmd" "arg" }}                              # Capture command output
```

---

## Scripts Reference

### Linux Scripts

| Script                                               | Purpose                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------- |
| `run_onchange_before_00_sudo.sh.tmpl`                | sudo: install, group membership, passwordless (`visudo -cf`)  |
| `run_onchange_before_10_os-install-packages.sh.tmpl` | Install apt packages by environment tag                       |
| `run_onchange_before_20_python-tools.sh.tmpl`        | Install uv + Python tools by environment tag                  |
| `run_onchange_before_90_chezmoi-package_install.sh.tmpl` | Replace chezmoi binary with `.deb` package               |
| `run_onchange_after_20_shell-zsh.sh.tmpl`            | Set zsh as default shell, refresh font cache                  |
| `run_onchange_after_60_wsl-conf.sh.tmpl`             | Configure `/etc/wsl.conf` — WSL only                          |
| `run_onchange_after_61_wsl-simlinks.sh.tmpl`         | Create home symlinks — WSL only                               |

### Shared Utilities (`home/.utils/utils.sh`)

```bash
source "{{ .chezmoi.sourceDir }}/.utils/utils.sh"

header "Section title"       # ===== Section title =====
step "Doing something..."    #   -->  Doing something...
info "Some information"      # [INFO]  Some information
success "It worked"          # [ OK ]  It worked
warning "Something odd"      # [WARN]  Something odd
error "Something failed"     # [ERR ]  Something failed >&2
command_exists "git"         # returns 0 if command found
require_tools git curl sudo  # exits with warning if any missing
```

---

## Development Workflows

### Edit and Apply

```bash
# Edit a managed file
chezmoi edit ~/.zshrc

# Preview changes before applying
chezmoi diff

# Apply changes
chezmoi apply

# Apply and see what runs
chezmoi apply --verbose
```

### Test Templates

```bash
# Render a template to stdout
chezmoi execute-template < home/dot_zshrc.tmpl

# Show rendered content of a deployed file
chezmoi cat ~/.zshrc

# Inspect template variables
chezmoi data
chezmoi data | grep -i wsl
```

### Force Re-run Scripts

```bash
# Re-run all run_onchange_ scripts (by clearing their state)
chezmoi state delete-bucket --bucket scriptState
chezmoi apply

# Re-run all run_once_ scripts
chezmoi state delete-bucket --bucket entryState
chezmoi apply
```

### Add New Dotfiles

```bash
# Add an existing file from home to the source
chezmoi add ~/.config/tool/config.yml
# → creates home/dot_config/tool/config.yml

# Edit then apply immediately
chezmoi edit --apply ~/.config/tool/config.yml

# Re-sync source from a file you edited directly in ~
chezmoi re-add ~/.config/tool/config.yml
```

**As a template** (to use variables like `.chezmoi.os`, `.name`...):

```bash
# Rename the source file to add .tmpl suffix
mv home/dot_config/tool/config.yml home/dot_config/tool/config.yml.tmpl
# Then use Go template syntax inside the file
```

**As a private file** (deployed with `0600` permissions):

```bash
chezmoi add --encrypt ~/.config/tool/secret.conf
# or simply prefix the source filename with private_:
# home/dot_config/tool/private_secret.conf → ~/.config/tool/secret.conf (0600)
```

**Exclude a file from chezmoi management** — add it to `.chezmoiignore.tmpl`:

```
# home/.chezmoiignore.tmpl
.config/tool/cache/
```

### Sync to All Machines

```bash
# On the editing machine — changes are auto-committed and pushed (autoCommit: true)
chezmoi apply

# On other machines
chezmoi update    # git pull + apply
```

---

## References

- [chezmoi documentation](https://www.chezmoi.io/)
- [chezmoi — Windows notes](https://www.chezmoi.io/user-guide/machines/windows/)
- [oh-my-zsh](https://ohmyz.sh/)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [yazi file manager](https://yazi-rs.github.io/)
- Inspiration:
  - [twpayne/dotfiles](https://github.com/twpayne/dotfiles)
  - [Install Doctor](https://install.doctor/docs)
