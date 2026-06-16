#!/usr/bin/env bash
# setup-env.sh - Unified environment setup script for cross-platform development
# Supports: macOS, Linux (WSL/Ubuntu/Debian)
# Uses: Homebrew, pnpm, uv (instead of pip) for secure, reproducible environment setup

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DOTFILES_DIR="${REPO_ROOT}/system/dotfiles"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Verify we're in the right directory
verify_repo() {
    if [[ ! -d "${REPO_ROOT}/.git" ]]; then
        log_error "This script must be run from within the Atlas repository"
        log_error "Current directory: $(pwd)"
        log_error "Expected to find .git in: ${REPO_ROOT}"
        exit 1
    fi
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            ;;
        Linux*)
            OS="linux"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    log_info "Detected OS: ${OS}"
}

# Check if running with sufficient privileges (for Linux package installation)
check_privileges() {
    if [[ "${OS}" == "linux" && "$EUID" -ne 0 ]]; then
        log_info "Some operations will require sudo privileges on Linux"
    fi
}

# Create necessary directories
setup_directories() {
    mkdir -p "${DOTFILES_DIR}"
    mkdir -p "${DOTFILES_DIR}/config"

    # Ensure local bin directory exists
    mkdir -p "${HOME}/.local/bin"

    # Ensure config directory exists
    mkdir -p "${HOME}/.config"
}

# Install system dependencies based on OS
install_system_dependencies() {
    log_info "Installing system dependencies..."

    if [[ "${OS}" == "macOS" ]]; then
        # macOS - Use Homebrew for everything
        if ! command -v brew >/dev/null 2>&1; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for this session
            if [[ "$(uname -m)" == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            log_info "Homebrew already installed, updating..."
            brew update
        fi

        # Install core packages via Homebrew
        log_info "Installing core packages via Homebrew..."
        BREW_PACKAGES=(
            # Shell and terminal
            zsh git tmux

            # Essential CLI tools (replacing defaults with better versions)
            bat eza fd fzf gh git-delta glow htop jq lazygit
            lazygit neovim ripgrep tealdeer tldr tree uv
            yq zoxide zsh-autosuggestions zsh-syntax-highlighting

            # Development tools
            go node npm  # Node via brew, but we'll use nvm for version management

            # Security and networking
            curl wget openssl

            # Productivity
            fzf
        )

        brew install "${BREW_PACKAGES[@]}"

        # Install casks (GUI applications if needed)
        log_info "Installing Homebrew casks..."
        BREW_CASKS=(
            # Add any GUI apps you need here
            # firefox
            # visual-studio-code
            # 1password
            # docker
        )

        if [[ ${#BREW_CASKS[@]} -gt 0 ]]; then
            brew install --cask "${BREW_CASKS[@]}"
        fi

    elif [[ "${OS}" == "linux" ]]; then
        # Linux - Use APT for system packages, Homebrew for user tools
        log_info "Updating APT package list..."
        sudo apt-get update -qq

        # Install essential system packages via APT
        log_info "Installing essential system packages via APT..."
        APT_PACKAGES=(
            build-essential curl git zsh htop tree unzip
            silversearcher-ag  # For ag (the silver searcher)
            python3-pip python3-venv  # Keep system pip for uv installation
            # Note: We avoid duplicating what we'll get via Homebrew/brew
        )

        sudo apt-get install -y "${APT_PACKAGES[@]}"

        # Install Homebrew on Linux if not present
        if ! command -v brew >/dev/null 2>&1; then
            log_info "Installing Homebrew on Linux..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for this session and persistently
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

            # Add to shell profile for persistence
            {
                echo ""
                echo "# Homebrew"
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
            } >> "${HOME}/.zprofile"

            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.profile"
        else
            log_info "Homebrew already installed, updating..."
            brew update
        fi

        # Install packages via Homebrew (avoiding duplicates with APT)
        log_info "Installing additional packages via Homebrew..."
        BREW_PACKAGES=(
            # Essential CLI tools (better versions than system defaults)
            bat eza exa fd fzf gh git-delta git-lfs htop jq lazygit
            lazygit neovim ripgrep tealdeer tldr tree uv yq zoxide

            # Shell enhancements
            zsh-autosuggestions zsh-syntax-highlighting powerlevel10k

            # Development tools that might be newer via brew
            go node  # We'll manage Node versions with nvm, but having system node helps

            # Security tools
            gnupg

            # Productivity
            fasd

            # Alternative shells
            fish
        )

        brew install "${BREW_PACKAGES[@]}"

        # Install Linuxbrew dependencies if needed
        if [[ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]]; then
            # Debian/Ubuntu specific
            sudo apt-get install -y build-essential curl file git
        fi
    fi
}

# Install and configure development tools
install_dev_tools() {
    log_info "Installing development tools..."

    # Install NVM (Node Version Manager) if not present
    if [[ ! -d "${HOME}/.nvm" ]]; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        # Load NVM for this session
        export NVM_DIR="${HOME}/.nvm"
        [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
    else
        log_info "NVM already installed"
        export NVM_DIR="${HOME}/.nvm"
        [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
    fi

    # Install and use latest LTS Node via NVM
    log_info "Installing latest LTS Node.js via NVM..."
    nvm install --lts
    nvm use --lts
    nvm alias default --lts

    # Install core global NPM packages (we'll use pnpm for most things)
    log_info "Installing essential global NPM packages..."
    NPM_PACKAGES=(
        pnpm  # Our primary package manager
    )

    npm install -g "${NPM_PACKAGES[@]}"

    # Configure pnpm
    log_info "Configuring pnpm..."
    pnpm config set store-dir "${HOME}/.local/share/pnpm/store"
    mkdir -p "${HOME}/.local/share/pnpm/store"

    # Install uv (Python package installer) if not already present
    if ! command -v uv >/dev/null 2>&1; then
        log_info "Installing uv (Python package installer)..."
        # Install via the official installer
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Ensure uv is in PATH for this session
        export PATH="${HOME}/.local/bin:${PATH}"
    else
        log_info "uv already installed"
    fi

    # Install some useful Python tools via uv (instead of pip)
    log_info "Installing useful Python tools via uv..."
    UV_TOOLS=(
        # Add any Python CLI tools you want here
        # for example: "ruff" "black" "isort" "mypy"
    )

    if [[ ${#UV_TOOLS[@]} -gt 0 ]]; then
        uv tool install "${UV_TOOLS[@]}" --python 3.12
    fi

    # Create uv virtual environment directory structure
    mkdir -p "${HOME}/.uv"
    mkdir -p "${HOME}/.cache/uv"
}

# Configure shell environment
configure_shell() {
    log_info "Configuring shell environment..."

    # Determine shell configuration files
    if [[ "${SHELL}" == *"zsh"* ]]; then
        SHELL_CONFIG="${HOME}/.zshrc"
        SHELL_ENV="${HOME}/.zshenv"
    elif [[ "${SHELL}" == *"bash"* ]]; then
        SHELL_CONFIG="${HOME}/.bashrc"
        SHELL_ENV="${HOME}/.bash_profile"
    else
        log_warning "Unsupported shell: ${SHELL}, skipping shell configuration"
        return
    fi

    # Backup existing shell config if it exists
    if [[ -f "${SHELL_CONFIG}" ]]; then
        cp "${SHELL_CONFIG}" "${SHELL_CONFIG}${BACKUP_SUFFIX}"
        log_info "Backed up existing ${SHELL_CONFIG} to ${SHELL_CONFIG}${BACKUP_SUFFIX}"
    fi

    # Generate shell configuration content
    CAT <<- SHELL_CONFIG_CONTENT > "${SHELL_CONFIG}"
# =============================================================================
# Atlas Development Environment Configuration
# Auto-generated by setup-env.sh - $(date)
# =============================================================================

# ---- PATH Configuration ----
# Local binaries
export PATH="${HOME}/.local/bin:\$PATH"

# Homebrew (Linux)
if [[ "$(uname)" == "Linux" && -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "\$($(which brew) shellenv)"
elif [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$(uname -m)" == "arm64" && -d "/opt/homebrew" ]]; then
        eval "\$($(which brew) shellenv)"
    elif [[ -d "/usr/local/bin" ]]; then
        eval "\$($(which brew) shellenv)"
    fi
fi

# NVM (Node Version Manager)
export NVM_DIR="\${HOME}/.nvm"
[ -s "\${NVM_DIR}/nvm.sh" ] && \. "\${NVM_DIR}/nvm.sh"  # This loads nvm
[ -s "\${NVM_DIR}/bash_completion" ] && \. "\${NVM_DIR}/bash_completion"  # This loads nvm bash_completion

# Pyenv (if used) - Optional
# export PYENV_ROOT="\${HOME}/.pyenv"
# export PATH="\${PYENV_ROOT}/bin:\$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "\$(pyenv init -)"
# fi

# ---- Tool-specific configurations ----

# PNPM
export PNPM_HOME="${HOME}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# UV (Python installer)
export UV_SYSTEM_PYTHON=1  # Use system Python when available
export UV_LINK_MODE=copy   # Prefer copying over linking for better compatibility

# ---- Editor configuration ----
export EDITOR='nvim'
export VISUAL='nvim'

# ---- History configuration ----
# Zsh history
if [[ "\$SHELL" == *"zsh"* ]]; then
    HISTSIZE=10000
    SAVEHIST=10000
    HISTFILE="\${HOME}/.zsh_history"
    setopt INC_APPEND_HISTORY TIME_EXTENDED_FORMAT
fi

# Bash history
if [[ "\$SHELL" == *"bash"* ]]; then
    HISTSIZE=10000
    HISTFILESIZE=20000
    shopt -s histappend
fi

# ---- Custom aliases and functions ----

# Better defaults
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Use neovim for vim if available
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
    alias vi='nvim'
    alias vimdiff='nvim -d'
fi

# Use bat for cat if available
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Use lsd for ls if available
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd'
    alias ll='lsd -la'
    alias la='lsd -A'
    alias l='lsd -l'
fi

# Use dust for du if available
if command -v dust >/dev/null 2>&1; then
    alias du='dust'
fi

# Use fd for find if available
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

# Use htop for top if available
if command -v htop >/dev/null 2>&1; then
    alias top='htop'
fi

# Use ncdu for disk usage if available
if command -v ncdu >/dev/null 2>&1; then
    alias du='ncdu'
fi

# Use ripgrep for grep if available
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi

# Use fzf for fuzzy finding
if command -v fzf >/dev/null 2>&1; then
    # Load fzf key bindings and completion
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Load custom aliases if they exist
[ -f "\${HOME}/.aliases" ] && source "\${HOME}/.aliases"

# Load local machine-specific config if it exists
[ -f "\${HOME}/.${SHELL##*/}rc.local" ] && source "\${HOME}/.${SHELL##*/}rc.local"

# =============================================================================
# End of Atlas Development Environment Configuration
# =============================================================================
SHELL_CONFIG_CONTENT

    log_success "Shell configuration updated: ${SHELL_CONFIG}"

    # Source the new config to apply changes in this session
    # Note: We do this carefully to avoid issues
    if [[ -f "${SHELL_CONFIG}" ]]; then
        log_info "To apply changes in this session, run: source ${SHELL_CONFIG}"
    fi
}

# Collect dotfiles from the current system
collect_dotfiles() {
    log_info "Collecting dotfiles from current system..."

    # List of files to collect
    local FILES_TO_COLLECT=(
        ".zshrc"
        ".tmux.conf"
        ".p10k.zsh"
        ".gitconfig"
        ".gitignore_global"
    )

    for file in "${FILES_TO_COLLECT[@]}"; do
        if [[ -f "${HOME}/${file}" ]]; then
            cp "${HOME}/${file}" "${DOTFILES_DIR}/"
            log_success "Copied ${file}"
        else
            log_warning "${file} not found in ${HOME}"
        fi
    done

    # Collect Neovim configuration
    if [[ -d "${HOME}/.config/nvim" ]]; then
        mkdir -p "${DOTFILES_DIR}/config/nvim"
        cp -r "${HOME}/.config/nvim/." "${DOTFILES_DIR}/config/nvim/"
        log_success "Copied Neovim configuration"
    else
        log_warning "Neovim configuration not found at ${HOME}/.config/nvim"
    fi

    # Collect any other config directories you might want
    # Add more as needed

    log_info "Dotfiles collection complete. Files stored in: ${DOTFILES_DIR}"
}

# Restore dotfiles to the system
restore_dotfiles() {
    log_info "Restoring dotfiles to system..."

    # List of files to restore
    local FILES_TO_RESTORE=(
        ".zshrc"
        ".tmux.conf"
        ".p10k.zsh"
        ".gitconfig"
        ".gitignore_global"
    )

    for file in "${FILES_TO_RESTORE[@]}"; do
        if [[ -f "${DOTFILES_DIR}/${file}" ]]; then
            # Backup existing file if it exists
            if [[ -f "${HOME}/${file}" ]]; then
                mv "${HOME}/${file}" "${HOME}/${file}${BACKUP_SUFFIX}"
                log_info "Backed up existing ${file} to ${file}${BACKUP_SUFFIX}"
            fi

            cp "${DOTFILES_DIR}/${file}" "${HOME}/${file}"
            log_success "Restored ${file}"
        else
            log_warning "${file} not found in dotfiles directory"
        fi
    done

    # Restore Neovim configuration
    if [[ -d "${DOTFILES_DIR}/config/nvim" ]]; then
        # Backup existing Neovim config if it exists
        if [[ -d "${HOME}/.config/nvim" ]]; then
            mv "${HOME}/.config/nvim" "${HOME}/.config/nvim${BACKUP_SUFFIX}"
            log_info "Backed up existing Neovim config to .config/nvim${BACKUP_SUFFIX}"
        fi

        mkdir -p "${HOME}/.config"
        cp -r "${DOTFILES_DIR}/config/nvim" "${HOME}/.config/"
        log_success "Restored Neovim configuration"
    else
        log_warning "Neovim configuration not found in dotfiles directory"
    fi

    log_info "Dotfiles restoration complete."
}

# Generate environment inventory
generate_inventory() {
    log_info "Generating environment inventory..."

    local INVENTORY_FILE="${DOTFILES_DIR}/package-inventory.md"
    {
        echo "# 📦 Current Environment Inventory"
        echo "_Generated on $(date) | $(uname -s)_"
        echo ""

        # ─── SYSTEM INFO ───
        echo "## 💻 System Information"
        echo "- **OS**: $(uname -s) $(uname -r) $(uname -m)"
        echo "- **Shell**: $SHELL"
        echo "- **Homebrew**: $(command -v brew && brew --version || echo "Not installed")"
        echo ""

        # ─── APT (Linux only) ───
        if [[ "${OS}" == "linux" && -x "$(command -v apt-mark)" ]]; then
            echo "## 🐧 APT (Manually Installed)"
            apt-mark showmanual 2>/dev/null | sort || echo "_None available_"
            echo ""
        fi

        # ─── HOMEBREW ───
        echo "## 🍺 Homebrew"
        if command -v brew >/dev/null 2>&1; then
            echo "### Formulae (explicitly installed)"
            brew leaves 2>/dev/null | sort || echo "_None_"
            echo -e "\n### Taps"
            brew tap 2>/dev/null | sort || echo "_None_"
        else
            echo "_Not available_"
        fi
        echo ""

        # ─── NPM/PNPM ───
        echo "## 📦 Package Managers"
        echo "### PNPM (Primary)"
        if command -v pnpm >/dev/null 2>&1; then
            echo "- **Version**: $(pnpm --version)"
            echo "- **Store directory**: $(pnpm config get store-dir)"
            echo ""
            echo "### Global Packages"
            pnpm list -g --depth=0 2>/dev/null | grep -v 'empty' || echo "_None_"
        else
            echo "_PNPM not found_"
        fi
        echo ""

        # ─── UV (Python) ───
        echo "## 🐍 Python (via uv)"
        if command -v uv >/dev/null 2>&1; then
            echo "- **Version**: $(uv --version)"
            echo "- **Python directory**: $(uv python list 2>/dev/null || echo "Managed by uv")"
            echo ""
            echo "### Installed Tools"
            uv tool list 2>/dev/null || echo "_None_"
        else
            echo "_uv not found_"
        fi
        echo ""

        # ─── NODE/NVM ───
        echo "## 🟢 Node.js (via NVM)"
        if command -v nvm >/dev/null 2>&1; then
            echo "- **NVM directory**: $NVM_DIR"
            echo "- **Default Node**: $(nvm version default 2>/dev/null || echo "Not set")"
            echo "- **Current Node**: $(node --version 2>/dev/null || echo "Not active")"
            echo ""
            echo "### Available Node Versions"
            nvm ls 2>/dev/null | grep -E 'v[0-9]' || echo "_None_"
        else
            echo "_NVM not found_"
        fi
        echo ""

        # ─── SHELL & TOOLS ───
        echo "## 🐚 Shell & Enhancements"
        echo "- **[ ] Oh My Zsh**: $( [[ -d "\$HOME/.oh-my-zsh" ]] && echo "Installed" || echo "Not installed" )"
        echo "- **[ ] Powerlevel10k**: $( [[ -f "\$HOME/.p10k.zsh" || -d "\$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] && echo "Installed" || echo "Not installed" )"
        echo "- **[ ] Zsh Autosuggestions**: $( command -v zsh-autosuggestions >/dev/null 2>&1 && echo "Installed" || echo "Not installed" )"
        echo "- **[ ] Zsh Syntax Highlighting**: $( command -v zsh-syntax-highlighting >/dev/null 2>&1 && echo "Installed" || echo "Not installed" )"
        echo ""

        # ─── ESSENTIAL CLI TOOLS ───
        echo "## 🔧 Essential CLI Tools"
        local TOOLS_TO_CHECK=(
            "git:Git"
            "zsh:Z Shell"
            "tmux:Terminal Multiplexer"
            "neovim:nvim"
            "nvim:Neovim"
            "bat:Better cat"
            "eza:Better ls"
            "fd:Better find"
            "fzf:Fuzzy finder"
            "ripgrep:Better grep"
            "jd:JSON processor"
            "jq:JSON query"
            "yq:YAML query"
            "zoxide:Better cd"
            "tldr:Simplified man pages"
            "tealdeer:Alternative tldr"
            "lazydocker:Docker UI"
            "lazygit:Git UI"
            "gh:GitHub CLI"
            "git-delta:Better diff"
            "uv:Python installer"
            "pnpm:Package manager"
            "node:Node.js"
            "go:Go language"
            "curl:URL transfer"
            "wget:Web download"
            "openssl:SSL toolkit"
            "gnupg:Encryption"
        )

        for tool_pair in "${TOOLS_TO_CHECK[@]}"; do
            IFS=':' read -r tool name <<< "$tool_pair"
            if command -v "$tool" >/dev/null 2>&1; then
                echo "- [x] $name: $(command -v "$tool")"
            else
                echo "- [ ] $name: Not found"
            fi
        done
        echo ""

        # ─── DIRECTORIES & PATHS ───
        echo "## 📁 Important Directories"
        echo "- **Dotfiles repo**: $REPO_ROOT"
        echo "- **Dotfiles storage**: $DOTFILES_DIR"
        echo "- **Local bin**: $HOME/.local/bin"
        echo "- **PNPM store**: $(pnpm config get store-dir 2>/dev/null || echo "Not configured")"
        echo "- **uv cache**: $HOME/.cache/uv"
        echo ""

    } > "$INVENTORY_FILE"

    log_success "Environment inventory saved to: $INVENTORY_FILE"
}

# Main setup function
main() {
    local MODE="${1:-help}"

    case "$MODE" in
        install)
            verify_repo
            detect_os
            check_privileges
            setup_directories
            install_system_dependencies
            install_dev_tools
            configure_shell
            collect_dotfiles
            generate_inventory
            log_success "Environment installation complete!"
            log_info "Please restart your terminal or run: source ~/.zshrc (or your shell config)"
            ;;
        restore)
            verify_repo
            detect_os
            setup_directories
            restore_dotfiles
            log_success "Dotfiles restoration complete!"
            ;;
        collect)
            verify_repo
            detect_os
            setup_directories
            collect_dotfiles
            log_success "Dotfiles collection complete!"
            ;;
        inventory)
            verify_repo
            detect_os
            setup_directories
            generate_inventory
            log_success "Inventory generation complete!"
            ;;
        help|*)
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  install   - Full environment installation (default)"
            echo "  restore   - Restore dotfiles from repository"
            echo "  collect   - Collect current dotfiles to repository"
            echo "  inventory - Generate environment inventory"
            echo "  help      - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 install     # Complete setup"
            echo "  $0 restore     # Just restore dotfiles"
            echo "  $0 collect     # Save current dotfiles"
            echo ""
            exit 0
            ;;
    esac
}

# Run main function with all arguments
main "$@"