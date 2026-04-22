#!/usr/bin/env bash
set -euo pipefail

OUTPUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dotfiles/package-inventory.md"
echo "# 📦 Current Environment Inventory" > "$OUTPUT"
echo "_Generated on $(date) | WSL2/Linux_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# ─── APT ───
echo "## 🐧 APT (Manually Installed)" >> "$OUTPUT"
if command -v apt-mark &>/dev/null; then
    apt-mark showmanual 2>/dev/null | sort >> "$OUTPUT"
else
    echo "_Not available_" >> "$OUTPUT"
fi
echo "" >> "$OUTPUT"

# ─── HOMEBREW ───
echo "## 🍺 Homebrew" >> "$OUTPUT"
if command -v brew &>/dev/null; then
    echo "### Formulae (explicitly installed)" >> "$OUTPUT"
    brew leaves 2>/dev/null | sort >> "$OUTPUT" || echo "_None_" >> "$OUTPUT"
    echo -e "\n### Taps" >> "$OUTPUT"
    brew tap 2>/dev/null | sort >> "$OUTPUT" || echo "_None_" >> "$OUTPUT"
else
    echo "_Not available_" >> "$OUTPUT"
fi
echo "" >> "$OUTPUT"

# ─── NPM ───
echo "## 📦 NPM (Global)" >> "$OUTPUT"
if command -v npm &>/dev/null; then
    npm list -g --depth=0 2>/dev/null | grep -v 'empty' >> "$OUTPUT" || echo "_None_" >> "$OUTPUT"
else
    echo "_Not available_" >> "$OUTPUT"
fi
echo "" >> "$OUTPUT"

# ─── CURL / MANUAL INSTALLS ───
echo "## 🌐 Curl / Script-Installed Tools" >> "$OUTPUT"
echo "> ⚠️ **Review & remove false positives before sharing.** \`curl | sh\` tools leave no central registry." >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "### Binaries in common manual paths" >> "$OUTPUT"
for dir in "$HOME/.local/bin" "/usr/local/bin" "$HOME/bin"; do
    if [[ -d "$dir" ]]; then
        found=$(ls -1 "$dir" 2>/dev/null | grep -vE '^\.' | sort)
        if [[ -n "$found" ]]; then
            echo "#### $dir" >> "$OUTPUT"
            echo "$found" >> "$OUTPUT"
        fi
    fi
done
echo "" >> "$OUTPUT"

echo "### Detected Version Managers & Toolchains" >> "$OUTPUT"
[[ -d "$HOME/.nvm" ]] && echo "- [ ] nvm (Node.js)" >> "$OUTPUT"
[[ -d "$HOME/.fnm" ]] && echo "- [ ] fnm (Node.js)" >> "$OUTPUT"
[[ -f "$HOME/.cargo/bin/cargo" ]] && echo "- [ ] rustup / cargo" >> "$OUTPUT"
[[ -d "$HOME/.rustup" ]] && echo "- [ ] rustup" >> "$OUTPUT"
[[ -d "$HOME/go/bin" || -d "$HOME/go" ]] && echo "- [ ] Go toolchain" >> "$OUTPUT"
[[ -d "$HOME/.pyenv" ]] && echo "- [ ] pyenv" >> "$OUTPUT"
[[ -d "$HOME/.oh-my-zsh" ]] && echo "- [ ] Oh My Zsh" >> "$OUTPUT"
[[ -f "$HOME/.p10k.zsh" || -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] && echo "- [ ] Powerlevel10k" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "### Standalone Binaries (curl-installed candidates)" >> "$OUTPUT"
for cmd in starship eza bat fzf lazygit ripgrep fd delta zoxide tmux neovim nvim jq yq just; do
    if command -v "$cmd" &>/dev/null; then
        echo "- [ ] $cmd (found at: $(command -v "$cmd"))" >> "$OUTPUT"
    fi
done
echo "" >> "$OUTPUT"
echo "✅ Inventory saved to: $OUTPUT"
