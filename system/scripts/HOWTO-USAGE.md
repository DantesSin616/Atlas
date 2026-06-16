# 📖 How to Use the Atlas Environment Setup Script

This document explains how to use the unified `setup-env.sh` script to manage your development environment across different machines and operating systems.

## 📋 Overview

The `setup-env.sh` script is a comprehensive, cross-platform environment setup tool that replaces the need for multiple separate scripts. It provides:

- **Unified interface** - One script for installation, restoration, collection, and inventory
- **Cross-platform support** - Works on macOS and Linux (WSL/Ubuntu/Debian)
- **Modern toolchain** - Uses Homebrew, pnpm, and uv instead of traditional approaches
- **Secure defaults** - No global pip installations, isolated environments
- **Dotfiles management** - Backup, restore, and track your configuration files
- **Inventory generation** - Create documentation of your installed packages

## 🚀 Getting Started

### Prerequisites
- Internet connection for downloading packages
- Supported OS: macOS (Intel or Apple Silicon), Linux (WSL2, Ubuntu/Debian recommended)
- Supported shells: bash, zsh
- On Linux: sudo privileges for APT package installation

### Location
The script is located at:
```
/home/daimo/repo/engineering/Atlas/system/scripts/setup-env.sh
```

Make sure it's executable:
```bash
chmod +x setup-env.sh
```

## 🔧 Available Commands

The script accepts one of these commands as its first argument:

| Command | Description |
|---------|-------------|
| `install` | Full environment installation (default) |
| `restore` | Restore dotfiles from repository |
| `collect` | Collect current dotfiles to repository |
| `inventory` | Generate environment inventory |
| `help` | Show help message |

### Examples
```bash
# Complete setup (recommended for new systems)
./setup-env.sh install

# Just restore your dotfiles from the repo
./setup-env.sh restore

# Backup your current configuration to the repo
./setup-env.sh collect

# Generate environment documentation
./setup-env.sh inventory

# Show help
./setup-env.sh help
```

## 🛠️ What Happens During Installation

When you run `./setup-env.sh install`, the script performs these steps:

### 1. **System Detection**
- Detects your operating system (macOS or Linux)
- Identifies your shell (bash or zsh)
- Checks for required dependencies (git, internet connectivity)

### 2. **Directory Setup**
- Creates necessary directories:
  - `~/dotfiles/` (for storing your configuration)
  - `~/dotfiles/config/` (for application configs like nvim)
  - `~/.local/bin/` (for local executables)
  - Ensures `~/.config/` exists

### 3. **Platform-Specific Dependency Installation**

#### **On macOS:**
- Installs/updates Homebrew if needed
- Installs core packages via Homebrew (git, zsh, tmux, neovim, etc.)
- Installs additional CLI tools (bat, eza, fd, fzf, rg, jq, etc.)
- Optionally installs GUI applications via Homebrew Cask

#### **On Linux:**
- Updates APT package list
- Installs essential system packages via APT (build-essential, curl, git, etc.)
- Installs/updates Homebrew for Linux if needed
- Installs additional user-level tools via Homebrew (avoiding APT duplicates)

### 4. **Development Tool Configuration**

#### **Node.js Ecosystem:**
- Installs NVM (Node Version Manager) if not present
- Installs and sets latest LTS Node.js via NVM
- Installs PNPM globally via npm
- Configures PNPM store directory

#### **Python Ecosystem:**
- Installs UV (Python package installer) if not present
- Optionally installs Python tools via UV (ruff, black, etc.)
- Configures UV for optimal performance

#### **Shell Configuration:**
- Backs up existing shell config (`.zshrc` or `.bashrc`)
- Generates new shell configuration with:
  - Proper PATH settings for all package managers
  - Useful aliases for modern CLI tools
  - History configuration
  - Editor preferences (neovim/vim)
  - Custom alias and function loading
- Sources the new configuration (requires restart for full effect)

### 5. **Dotfiles Management**
- Collects your current dotfiles for backup:
  - Shell configs (`.zshrc`, `.bashrc`)
  - Git configs (`.gitconfig`, `.gitignore_global`)
  - Terminal multiplexer (`.tmux.conf`)
  - Powerlevel10k config (`.p10k.zsh`)
  - Neovim configuration (`~/.config/nvim/`)
- Stores them in the repository's `dotfiles/` directory

### 6. **Inventory Generation**
- Creates `dotfiles/package-inventory.md` documenting:
  - System information
  - Installed packages (APT, Homebrew, PNPM, UV, NVM)
  - Available Node.js versions
  - Installed essential CLI tools
  - Important directories

## 🔄 Dotfiles Management Workflow

The script provides three complementary workflows for managing your configuration:

### Backup Your Current Setup
```bash
./setup-env.sh collect
```
This copies your current dotfiles to the repository, overwriting any existing ones there.

### Restore from Repository
```bash
./setup-env.sh restore
```
This copies dotfiles FROM the repository TO your home directory, automatically backing up any existing files first.

### Full Environment Setup
```bash
./setup-env.sh install
```
This does everything: installs tools, configures shell, collects dotfiles, and generates inventory.

## 🔒 Security Features

1. **No Global Python Installs**: Uses uv for isolated Python environments instead of pip
2. **Secure Package Management**: PNPM provides integrity checking and reproducible installs
3. **Automatic Backups**: Files are backed up with timestamps before being overwritten
4. **Path Isolation**: Local bins go in `~/.local/bin` to avoid system conflicts
5. **Minimal Privileges**: Only uses sudo when absolutely necessary (Linux APT installs)

## 🎯 Toolchain Choices Explained

### Why Homebrew?
- Cross-platform (macOS and Linux)
- Large, active community
- Builds from source when possible
- Easy to install/update/remove packages

### Why PNPM?
- **Faster** than npm/yarn (uses content-addressable storage)
- **More secure** (strict integrity checking)
- **Disk efficient** (shares dependencies across projects)
- **Compatible** with existing npm workflows

### Why UV?
- **Extremely fast** (written in Rust)
- **Replaces pip, pip-tools, virtualenv, poetry, etc.**
- **No global installs** by default (uses isolated environments)
- **Modern** Python packaging standards compliance

### Why NVM?
- Allows multiple Node.js versions
- Easy switching between versions
- Isolated per-user installations
- No sudo required for global packages

## 🛠️ Customization

### Adding Custom Packages
Edit these arrays in `setup-env.sh` to add packages to your installation:

- **BREW_PACKAGES** - Homebrew formulae (both platforms)
- **APT_PACKAGES** - Debian/Ubuntu packages (Linux only)
- **NPM_PACKAGES** - Global npm packages (installed via PNPM)
- **UV_TOOLS** - Python tools installed via uv

### Custom Dotfiles
To manage additional files, edit these arrays:
- **FILES_TO_COLLECT/FILES_TO_RESTORE** - Individual files
- Add directory copying logic in the `collect_dotfiles()` and `restore_dotfiles()` functions

### Shell Configuration
The generated shell config includes sections for:
- PATH configuration
- Tool-specific settings (PNPM, UV, NVM, etc.)
- Editor preferences
- History settings
- Useful aliases
- Custom alias loading (`~/.aliases`)
- Local overrides (`~/.{shell}rc.local`)

Add your customizations to these files instead of modifying the generated config directly.

## 📁 Directory Structure

After running the script, your setup will look like this:

```
~/
├── .local/
│   └── bin/              # Local executables
│       └── pnpm          # PNPM binary
├── .cache/
│   └── uv/               # UV cache
├── .config/
│   └── nvim/             # Neovim configuration
├── .zshrc                # Zsh configuration (backed up/restored)
├── .tmux.conf            # Tmux configuration
├── .p10k.zsh             # Powerlevel10k configuration
├── .gitconfig            # Git configuration
└── .gitignore_global     # Global git ignore
```

Repository structure:
```
Atlas/
├── system/
│   └── scripts/
│       ├── setup-env.sh          # Main script
│       ├── README.md             # Basic overview
│       ├── HOWTO-USAGE.md        # This file
│       ├── collect-configs.sh    # Legacy (backward compatibility)
│       ├── restore.sh            # Legacy (backward compatibility)
│       ├── generate-inventory.sh # Legacy (backward compatibility)
│       └── dotfiles/
│           ├── package-inventory.md    # Environment inventory
│           ├── .zshrc                  # Your zsh config
│           ├── .tmux.conf              # Your tmux config
│           ├── .p10k.zsh               # Your powerlevel10k config
│           ├── .gitconfig              # Your git config
│           ├── .gitignore_global       # Your global git ignore
│           └── config/
│               └── nvim/               # Your neovim config
```

## ⚙️ Requirements & Compatibility

### Supported Operating Systems
- **macOS**: 10.15+ (Catalina) and later (Intel and Apple Silicon)
- **Linux**: Ubuntu 20.04+, Debian 11+, WSL2
- *Other distributions may work but are not officially tested*

### Supported Shells
- **bash**: 4.0+
- **zsh**: 5.0+
- *Fish and other shells are not currently supported*

### Required Permissions
- **macOS**: Standard user permissions (Homebrew installs to user directory)
- **Linux**: 
  - Standard user for most operations
  - **sudo** for APT package installation (required)

### Disk Space
- Minimum: ~2GB for basic installation
- Recommended: 5GB+ for full development toolchain
- UV caches and PNPM store will grow with usage

## 🔍 Troubleshooting

### Common Issues & Solutions

#### 1. **"command not found" after installation**
- **Cause**: PATH changes require new shell session
- **Solution**: 
  ```bash
  source ~/.zshrc   # or source ~/.bashrc
  ```
  Or simply restart your terminal

#### 2. **Permission errors on Linux**
- **Cause**: Missing sudo privileges for APT installation
- **Solution**: 
  ```bash
  sudo ./setup-env.sh install
  ```
  The script will only use sudo when necessary

#### 3. **Homebrew not found after installation**
- **Cause**: Homebrew not in PATH for current session
- **Solution**:
  ```bash
  # For Linux
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  
  # For macOS Intel
  test -d /usr/local/bin && eval "$(/usr/local/bin/brew shellenv)"
  
  # For macOS Apple Silicon
  test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
  ```

#### 4. **Shell configuration not taking effect**
- **Cause**: Shell doesn't match detected type
- **Solution**: 
  - Check your shell: `echo $SHELL`
  - Ensure it's either bash or zsh
  - The script detects from `$SHELL` environment variable

#### 5. **UV/PNPM commands not found**
- **Cause**: Local bin directory not in PATH
- **Solution**:
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  # Add this to your shell config for permanence
  ```

### Getting Help
If you encounter issues:
1. Re-run with verbose output: `bash -x ./setup-env.sh install`
2. Check the script's error messages - they're designed to be helpful
3. Ensure you meet the prerequisites listed above
4. Consult the script's source code for detailed logic

## 🔄 Updating Your Environment

To update your environment to match changes in the repository:

1. **Update the repository first**:
   ```bash
   cd /home/daimo/repo/engineering/Atlas
   git pull
   ```

2. **Run the install command again**:
   ```bash
   cd system/scripts
   ./setup-env.sh install
   ```
   The script is designed to be safely re-runnable - it will:
   - Skip already installed packages
   - Update configurations if changed
   - Preserve your local customizations
   - Back up files before overwriting

## 📝 License & Attribution

This script is provided as-is under the MIT License. Feel free to modify, adapt, and redistribute for your own use.

**Inspired by**: Various dotfiles frameworks and environment setup scripts from the open-source community.

**Created for**: Personal development environment management across multiple machines and operating systems.

## ❓ Frequently Asked Questions

### Q: Can I use this on a fresh system?
**A**: Yes! The `install` command is designed for fresh systems. It will install all required dependencies and configure your environment from scratch.

### Q: Will this overwrite my existing configuration?
**A**: The script automatically backs up existing files before overwriting them. Backups are timestamped (e.g., `.zshrc.bak.20260616_011316`) and can be restored manually if needed.

### Q: How secure is this script?
**A**: The script follows security best practices:
- No global pip installations (uses uv instead)
- Uses package managers with integrity checking (Homebrew, PNPM)
- Creates backups before modifying files
- Only requests privileges when necessary (sudo on Linux for APT)
- Sources code only from trusted locations (official installers)

### Q: Can I use this with my existing dotfiles?
**A**: Absolutely! The `collect` command will back up your current configuration to the repository, and `restore` will deploy it elsewhere.

### Q: What if I don't want some of the installed tools?
**A**: You can customize the package arrays in the script, or simply uninstall specific tools afterward using their respective package managers (brew uninstall, pnpm remove, uv tool uninstall).

### Q: How does this compare to other dotfile managers?
**A**: Unlike specialized dotfile managers (like homesick, yadm, or chezmoi), this script focuses on:
- Complete environment setup (not just dotfiles)
- Cross-platform package management
- Modern toolchain recommendations
- Opinionated but customizable defaults
- Simplicity and transparency

### Q: Can I contribute improvements?
**A**: Yes! Feel free to fork the repository and submit pull requests with improvements, or open issues for feature requests and bug reports.

---

## 🎉 Next Steps

Once you've run `./setup-env.sh install`:

1. **Restart your terminal** to fully load the new configuration
2. **Verify installations**:
   ```bash
   brew --version       # Homebrew
   pnpm --version       # PNPM
   uv --version         # UV
   nvm --version        # NVM
   node --version       # Node.js
   ```
3. **Explore your new tools**:
   ```bash
   bat ~/.zshrc         # See your config with syntax highlighting
   eza -la              # Modern ls replacement
   fzf                  # Try the fuzzy finder
   tig                  # Git interface (if installed)
   ```
4. **Customize further** by editing:
   - `~/.aliases` for personal shortcuts
   - `~/.{shell}rc.local` for machine-specific settings
   - `~/.config/nvim/` for Neovim preferences

Your development environment is now set up with a modern, secure, and consistent toolchain that you can easily replicate on any supported machine!

*Happy coding!* 🚀