# dotfiles

My dotfiles management with [chezmoi](https://www.chezmoi.io).

## Installation

To install the dotfiles, run the following command:

```shell
sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
```

## Project Structure

The project is organized as follows:

- `.chezmoiroot`: Root directory for chezmoi.
- `.chezmoiversion`: Version file for chezmoi.
- `install.sh`: Installation script.
- `home/`: Directory containing dotfiles and configuration templates.
  - `.chezmoi.yaml.tmpl`: Main chezmoi configuration template.
    - This file is the main configuration file for chezmoi. It includes default values for various settings, OS information, prompts for user input during initialization, hooks for installing a password manager, data section with user information, edit command, Bitwarden configuration, and Git configuration.
  - `.chezmoiexternal.yaml.tmpl`: External templates configuration.
    - This file defines external templates for various tools and configurations. It includes conditions for installing these templates based on user input and OS type.
  - `.chezmoiignore`: Files and directories to ignore in chezmoi.
    - This file specifies files and directories that chezmoi should ignore. It includes conditions for ignoring files based on user input and OS type.
  - `.bashrc`: Bash shell configuration.
  - `.gitconfig.tmpl`: Git configuration template.
  - `.nanorc`: Nano text editor configuration.
  - `.p10k.zsh`: Powerlevel10k Zsh theme configuration.
  - `.sh_aliases.tmpl`: Shell aliases template.
  - `.zshrc`: Zsh shell configuration.
  - `dot_config/neofetch/config.conf`: Neofetch configuration.
  - `dot_ssh/`: SSH configuration and keys.
  - `exact_dot_oh-my-zsh/`: Oh-my-zsh configuration and completions.

### Dynamic Configuration Files

Configuration files with the `.tmpl` extension can be dynamic based on templates. These templates allow for variable substitution and conditional logic, making the configuration files adaptable to different environments and use cases.

## Configuration

### chezmoi Configuration

The `.chezmoi.yaml.tmpl` file is the main configuration file for chezmoi. It includes:

- Default values for various settings (private, work, ephemeral, headless, interactive, debug_hooks).
- OS information and detection for WSL.
- Prompts for user input during initialization (private mode, install ZSH, change default shell).
- Hooks for installing a password manager if private mode is enabled.
- Data section with user information and configuration options.
- Edit command set to nano.
- Bitwarden configuration for auto-unlock.
- Git configuration for auto-commit and auto-push.

## Deployment Process

### Installation Script (`install.sh`)

The `install.sh` script performs the following actions:

1. **Checks for chezmoi Installation**: Verifies if chezmoi is already installed.
2. **Installs chezmoi**: If chezmoi is not found, it installs chezmoi to the `~/.local/bin` directory using either `curl` or `wget`.
3. **Initializes and Applies Dotfiles**: Provides a menu for the user to choose between:
   - Initializing chezmoi.
   - Initializing and applying dotfiles.
   - Initializing and applying dotfiles with the `--one-shot` option.
   - Quitting the script.

### Initializing chezmoi

To initialize chezmoi with the dotfiles, run the following command:

```shell
chezmoi init https://github.com/phenates/dotfiles.git
```

This command will clone the dotfiles repository and set up the chezmoi configuration. During initialization, chezmoi performs the following actions:

1. **Clones the Repository**: Downloads the dotfiles repository from the specified URL to the source directory.
2. **Configures chezmoi**: Sets up the chezmoi configuration based on the `.chezmoi.yaml.tmpl` file.

### Applying Dotfiles

To apply the dotfiles to your system, run the following command:

```shell
chezmoi apply
```

This command will synchronize the dotfiles from the source directory to your destination directory (usually your home directory). During the apply process, chezmoi performs the following actions:

1. **Updates Templates**: Re-applies any templates that have changed in the source directory.
2. **Installs New Files**: Adds any new files or directories that have been added to the source directory.
3. **Removes Obsolete Files**: Deletes any files or directories that have been removed from the source directory.
4. **Updates Configuration**: Applies any changes to the configuration files.
5. **Runs Hooks**: Executes any hooks defined in the configuration.

### Managing Updates

To update your dotfiles to the latest version from the repository, run:

```shell
chezmoi update
```

This command will pull the latest changes from the repository and apply them to your system. During the update process, chezmoi performs the following actions:

1. **Pulls Changes**: Downloads the latest changes from the repository to the source directory.
2. **Applies Updates**: Re-applies any updated templates and configuration files from the source directory to the destination directory.
3. **Installs New Files**: Adds any new files or directories that have been added to the source directory.
4. **Removes Obsolete Files**: Deletes any files or directories that have been removed from the source directory.
5. **Runs Hooks**: Executes any hooks defined in the configuration.
