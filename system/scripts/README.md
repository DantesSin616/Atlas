# Environment Setup Scripts

This directory contains scripts for managing a consistent development environment across different machines and operating systems.

## Overview

The environment setup system consists of:

1. **`setup-env.sh`** - Unified cross-platform environment setup script
2. **`collect-configs.sh`** - Legacy script for collecting dotfiles (kept for compatibility)
3. **`restore.sh`** - Legacy script for restoring environment (kept for compatibility)
4. **`generate-inventory.sh`** - Legacy script for generating package inventory (kept for compatibility)

## Features

The unified `setup-env.sh` script provides:

- **Cross-platform support**: Works on macOS and Linux (WSL/Ubuntu/Debian)
- **Modern toolchain**: Uses Homebrew, pnpm, and uv instead of traditional package managers
- **Secure defaults**: No global pip installations, uses uv for Python package management
- **Dotfiles management**: Collect, restore, and backup your configuration files
- **Inventory tracking**: Generate markdown documentation of your installed packages
- **Shell configuration**: Automatically configures zsh/bash with sensible defaults and aliases

## Usage

### Full Installation
```bash
# From the scripts directory
./setup-env.sh install
```

This will:
1. Detect your operating system
2. Install system dependencies (APT on Linux, Homebrew on macOS)
3. Install and configure development tools (NVM, Node.js, pnpm, uv)
4. Set up shell configuration (zsh/bash)
5. Collect your current dotfiles for backup
6. Generate an environment inventory

### Dotfiles Management
```bash
# Collect current dotfiles to the repository
./setup-env.sh collect

# Restore dotfiles from the repository
./setup-env.sh restore

# Generate environment inventory documentation
./setup-env.sh inventory
```

### Legacy Scripts
The original scripts are still available for backward compatibility:
- `./collect-configs.sh` - Collect dotfiles
- `./restore.sh` - Full environment restore (Linux-focused)
- `./generate-inventory.sh` - Generate package inventory

## What Gets Installed

### Package Managers
- **Homebrew** (for macOS and Linux user packages)
- **PNPM** (primary Node.js package manager - faster and more secure than npm/yarn)
- **uv** (ultra-fast Python package installer and resolver - replaces pip)

### Development Tools
- **Node.js** (via NVM for version management)
- **Python** (via uv for isolated environments)
- **Go** (via Homebrew/APT)
- **Git** and related tools (gh, git-delta, lazygit)
- **Shell** (zsh with Oh My Zsh, Powerlevel10k, autosuggestions, syntax highlighting)
- **Editor** (Neovim with basic configuration)
- **Terminal** (tmux)

### Enhanced CLI Tools (Better Defaults)
- `bat` (cat with syntax highlighting)
- `eza`/`lsd` (modern ls replacements)
- `fd` (find alternative)
- `fzf` (fuzzy finder)
- `ripgrep` (grep alternative)
- `jq`/`yq` (JSON/YAML processors)
- `zoxide` (smart cd command)
- `tldr`/`tealdeer` (simplified man pages)
- `htop` (system monitoring)
- `lazydocker`/`lazygit` (Docker/Git UIs)

### Shell Configuration
The script configures your shell with:
- Proper PATH settings for all package managers
- Useful aliases for common commands
- History configuration
- Auto-loading of completions and key bindings
- Support for local machine-specific overrides

## Security Considerations

1. **No global pip installations**: Uses uv for isolated Python environments
2. **PNPM over npm/yarn**: More secure package management with integrity checking
3. **Homebrew formulae**: Preferentially uses Homebrew packages which are built from source
4. **Dotfile backups**: Existing files are backed up before being overwritten
5. **Path isolation**: Local binaries go in `~/.local/bin` to avoid system conflicts

## Customization

### Adding Custom Packages
To add additional packages to the installation, modify the arrays in `setup-env.sh`:
- `BREW_PACKAGES` for Homebrew packages
- `APT_PACKAGES` for Linux system packages (Linux only)
- `NPM_PACKAGES` for global npm packages
- `UV_TOOLS` for Python tools installed via uv

### Custom Dotfiles
The script automatically collects and restores:
- Shell configs (`.zshrc`, `.bashrc`)
- Git configs (`.gitconfig`, `.gitignore_global`)
- Terminal multiplexer config (`.tmux.conf`)
- Powerlevel10k config (`.p10k.zsh`)
- Neovim configuration (`~/.config/nvim/`)

To add more files, edit the `FILES_TO_COLLECT` and `FILES_TO_RESTORE` arrays in the script.

## Requirements

- **Internet connection** for downloading packages
- **sudo privileges** on Linux for APT package installation
- **Supported OS**: macOS (Intel or Apple Silicon), Linux (WSL2, Ubuntu/Debian recommended)
- **Supported shells**: bash, zsh

## Troubleshooting

### Common Issues

1. **Command not found after installation**
   - Restart your terminal or run: `source ~/.zshrc` (or your shell config)
   - The script modifies your PATH, which requires a new shell session

2. **Permission errors on Linux**
   - Ensure you run the install command with sufficient privileges
   - The script will prompt for sudo when needed

3. **Conflicting Homebrew installations**
   - If you have both Linuxbrew and Homebrew, the script uses the standard location
   - Existing installations at `~/.linuxbrew` or `/home/linuxbrew/.linuxbrew` are used

4. **Shell configuration not loading**
   - Check that your shell is actually zsh or bash
   - The script detects your shell from `$SHELL` environment variable

### Getting Help
```bash
./setup-env.sh help
```

## License
MIT License - feel free to modify and adapt for your own use.

## Acknowledgments
Inspired by various dotfiles frameworks and environment setup scripts from the community.