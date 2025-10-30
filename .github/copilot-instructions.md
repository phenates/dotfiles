# AI Agent Instructions for Dotfiles Repository

This repository uses [chezmoi](https://www.chezmoi.io) for dotfiles management. These instructions will help AI agents understand the repository structure and patterns.

## Project Architecture

### Key Components

- **Template System**: Files with `.tmpl` extension use chezmoi's templating for dynamic configuration
  - Example: `home/dot_gitconfig.tmpl` for conditional Git configuration
  - Template variables are defined in `home/.chezmoi.yaml.tmpl`

### Directory Structure

- `home/` - Source directory containing all dotfiles
  - `dot_*` - Regular dotfiles (e.g., `dot_zshrc` → `.zshrc`)
  - `private_dot_*` - Private dotfiles (e.g., `private_dot_gitconfig.tmpl` → `.gitconfig`)
  - `dot_config/` - XDG config directory contents
  - `dot_local/` - User-local binaries and data
  - `dot_oh-my-zsh/` - ZSH configuration and plugins

## Development Workflows

### Testing Changes

1. Make changes to source files in the `home/` directory
2. Use `chezmoi apply` to test changes
3. Use `chezmoi diff` to review changes before committing

### Common Patterns

- Use `.tmpl` extension for files needing dynamic content
- Prefix filenames with:
  - `dot_` for dotfiles
  - `private_dot_` for sensitive files
  - `executable_` for executable files
- Place shell functions in `dot_sh_functions.tmpl`
- Place shell aliases in `dot_sh_aliases.tmpl`

## Integration Points

- **SSH Keys**: Managed in `dot_ssh/` with public/private key pairs
- **Shell Integration**:
  - ZSH configuration in `dot_zshrc`
  - Bash configuration in `dot_bashrc`
  - Common aliases in `dot_sh_aliases.tmpl`
- **Git Integration**: Template-based config in `private_dot_gitconfig.tmpl`

## Project-Specific Conventions

1. Template Variables:

   ```
   {{ .chezmoi.os }}        - Operating system detection
   {{ .chezmoi.hostname }}  - Host machine name
   {{ .private }}           - Private mode flag
   {{ .interactive }}       - Interactive mode flag
   ```

2. Configuration Hierarchy:
   - Base settings in regular files
   - Host-specific overrides via templates
   - Private settings in `private_*` files

Remember to use `chezmoi` commands instead of directly editing files in the home directory.
