# =============================================================================
# 1. ENVIRONMENT & PATH (Must be at the very top)
# =============================================================================

# CRITICAL: Restore system PATH first before anything else
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Homebrew Setup (Sets PATH and HOMEBREW_PREFIX)
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Bootdev CLI Setup - CORRECT PATH
export PATH="$HOME/.local/opt/go-bin-v1.25.5/bin:$PATH"
if command -v bootdev &> /dev/null; then
  eval "$(bootdev completion zsh)" 2>/dev/null || true
fi

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Editor
export EDITOR=nvim
export VISUAL=nvim

# Terminal settings
export TERM=xterm-256color

# =============================================================================
# 2. PLUGIN INITIALIZATION (Before compinit, after PATH)
# =============================================================================

# Powerlevel10k Instant Prompt - MUST stay near top
typeset -g POWERLEVEL10K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zoxide Initialization
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)" 2>/dev/null || true
fi

# FZF Initialization
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)" 2>/dev/null || true
fi

# Source Plugins using HOMEBREW_PREFIX
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  source ${HOMEBREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme 2>/dev/null
  source ${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
  source ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
fi

# Load P10K Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# 3. ALIASES & FUNCTIONS (After tools are initialized)
# =============================================================================

# Safer CD alias
if typeset -f z > /dev/null; then
  alias cd='z'
fi

alias brew-up="brew update && brew upgrade"
alias apt-up="sudo apt update && sudo apt full-upgrade -y"
alias c='cd'
alias docker='lazydocker'
alias ls='eza --icons'
alias cat='bat'
alias help='tldr'
alias vim=nvim
alias v=nvim

# FZF with bat preview
alias p='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Zed IDE Function
zed() {
    if [ $# -eq 0 ]; then
        zed.exe .
    else
        local args=()
        for arg in "$@"; do
            if [[ -e "$arg" ]]; then
                args+=("$(wslpath -w "$arg")")
            else
                args+=("$arg")
            fi
        done
        zed.exe "${args[@]}"
    fi
}

# Fix prompt redraw on terminal resize
function _p10k_resize_handler() {
  zle && zle reset-prompt
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _p10k_resize_handler

# =============================================================================
# 4. COMPLETION (Must be at the very end)
# =============================================================================

# Fix broken Docker completion symlink (one-time cleanup)
if [[ -L /usr/share/zsh/vendor-completions/_docker ]] && [[ ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
  rm -f /usr/share/zsh/vendor-completions/_docker 2>/dev/null
fi

# Run compinit safely
autoload -Uz compinit
compinit -C 2>/dev/null
