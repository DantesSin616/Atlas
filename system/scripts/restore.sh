#!/usr/bin/env bash
# restore.sh - Automated environment setup based on package-inventory.md

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dotfiles"

echo "🚀 Starting environment restoration..."

# 1. APT Packages
echo "🐧 Installing APT packages..."
APT_PACKAGES=(
    build-essential curl git zsh htop tree unzip
    fd-find lsd lua5.1 lua5.4 pipx python3-pip
)
sudo apt update
sudo apt install -y "${APT_PACKAGES[@]}"

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to path for the current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "🍺 Updating Homebrew and installing formulae..."
brew tap steipete/tap
brew tap yakitrak/yakitrak
BREW_FORMULAE=(
    bat btop dust eza fastfetch fd fzf gh git-delta go
    lazydocker lazygit neovim powerlevel10k ripgrep tldr
    uv xsel zoxide zsh-autosuggestions zsh-syntax-highlighting
)
brew install "${BREW_FORMULAE[@]}"

# 3. NVM & NPM
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "📦 Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

echo "📦 Installing global NPM packages..."
# Ensure node is installed
nvm install --lts
NPM_PACKAGES=(
    @google/gemini-cli
    tree-sitter-cli
    openclaw
)
npm install -g "${NPM_PACKAGES[@]}"

# 4. Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 5. Restore Dotfiles
echo "📂 Restoring configuration files..."
FILES=(
    ".zshrc"
    ".tmux.conf"
    ".p10k.zsh"
)

for file in "${FILES[@]}"; do
    if [[ -f "$DOTFILES_DIR/$file" ]]; then
        # Backup existing if any
        [[ -f "$HOME/$file" ]] && mv "$HOME/$file" "$HOME/${file}.bak"
        cp "$DOTFILES_DIR/$file" "$HOME/$file"
        echo "✅ Restored $file"
    fi
done

# Restore nvim config
if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
    mkdir -p "$HOME/.config"
    [[ -d "$HOME/.config/nvim" ]] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    cp -r "$DOTFILES_DIR/config/nvim" "$HOME/.config/"
    echo "✅ Restored nvim config"
fi

echo "✨ Environment restoration complete! Please restart your terminal."
