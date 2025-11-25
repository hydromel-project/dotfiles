# ============================================================================
# Configuration Constants
# ============================================================================
readonly ZSHRC_FZF_UPDATE_DAYS=7
readonly ZSHRC_TOOL_CHECK_HOURS=24
readonly ZSHRC_FZF_MENU_HEIGHT="40%"
readonly ZSHRC_BAT_THEME="TwoDark"

# ============================================================================
# PATH Configuration
# ============================================================================
export PATH="$HOME/.fzf/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/share/pnpm:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ============================================================================
# Core Helper Functions
# ============================================================================
_has_command() {
  command -v "$1" &> /dev/null
}

_is_installed() {
  _has_command "$1" && echo 1 || echo 0
}

_get_bat_command() {
  _has_command batcat && echo "batcat" || echo "bat"
}

_timestamp_now() {
  date +%s
}

_hours_since_timestamp() {
  local timestamp=$1
  local now=$(_timestamp_now)
  echo $(( (now - timestamp) / 3600 ))
}

_days_since_timestamp() {
  local timestamp=$1
  local now=$(_timestamp_now)
  echo $(( (now - timestamp) / 86400 ))
}

# ============================================================================
# Tool Availability Checks
# ============================================================================
_HAS_FD=$(_is_installed fd)
_HAS_BAT=0
_has_command bat && _HAS_BAT=1
_has_command batcat && _HAS_BAT=1
_HAS_EZA=$(_is_installed eza)
_HAS_ZOXIDE=$(_is_installed zoxide)
_HAS_FZF=$(_is_installed fzf)
_HAS_NVIM=$(_is_installed nvim)
_HAS_XCLIP=$(_is_installed xclip)
_HAS_TMUX=$(_is_installed tmux)

# Extended tools (bonus features)
_HAS_RIPGREP=$(_is_installed rg)
_HAS_DELTA=$(_is_installed delta)
_HAS_LAZYGIT=$(_is_installed lazygit)
_HAS_TLDR=0
_has_command tldr && _HAS_TLDR=1
_has_command tealdeer && _HAS_TLDR=1
_HAS_DUST=$(_is_installed dust)
_HAS_PROCS=$(_is_installed procs)
_HAS_BTOP=$(_is_installed btop)

# Deno
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  export FPATH="$HOME/.zsh/completions:$FPATH"
fi
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ============================================================================
# Oh My Zsh
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # Overridden by Starship anyway

# Plugins - removed zsh-autocomplete (conflicts with zsh-autosuggestions)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo                      # ESC ESC to add sudo
  command-not-found         # Suggest package for missing commands
  extract                   # Smart archive extraction (x <file>)
  colored-man-pages         # Colorful man pages
  docker
  docker-compose
  tmux                      # Tmux shortcuts and completion
  history-substring-search  # Better history search
  web-search                # Search from terminal (google, ddg, etc)
  copypath                  # Copy current path to clipboard (copypath)
  copyfile                  # Copy file content to clipboard (copyfile <file>)
  aliases                   # Quick alias search (als <keyword>)
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# Environment
# ============================================================================
export EDITOR="nvim"
export VISUAL="nvim"

# Locale configuration (fixes perl warnings)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ============================================================================
# History Optimization
# ============================================================================
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Record timestamp
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't show duplicates in search
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt SHARE_HISTORY             # Share history across sessions

# ============================================================================
# Completions
# ============================================================================
autoload -Uz compinit
# Speed up compinit by only checking once per day
# -i flag ignores insecure directories/files
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i
else
  compinit -C -i
fi

# Completion optimization
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ============================================================================
# FZF Auto-Install/Update
# ============================================================================
_fzf_should_check_updates() {
  local check_file="$HOME/.fzf_last_update_check"

  [[ ! -f "$check_file" ]] && return 0

  local last_check=$(cat "$check_file")
  local days_since=$(_days_since_timestamp "$last_check")

  [[ $days_since -ge $ZSHRC_FZF_UPDATE_DAYS ]]
}

_fzf_install() {
  local fzf_dir="$HOME/.fzf"

  echo "📦 fzf not found. Installing..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
  "$fzf_dir/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
}

_fzf_update_if_needed() {
  local fzf_dir="$HOME/.fzf"
  local check_file="$HOME/.fzf_last_update_check"

  cd "$fzf_dir" || return
  git fetch --quiet origin

  local local_commit=$(git rev-parse HEAD)
  local remote_commit=$(git rev-parse origin/master)

  if [[ "$local_commit" != "$remote_commit" ]]; then
    git pull --quiet origin master
    "$fzf_dir/install" --key-bindings --completion --no-update-rc --no-bash --no-fish > /dev/null 2>&1
    echo "✓ fzf updated to latest version" >&2
  fi

  _timestamp_now > "$check_file"
}

_fzf_auto_setup() {
  local fzf_dir="$HOME/.fzf"

  [[ ! -d "$fzf_dir" ]] && _fzf_install && return

  _fzf_should_check_updates || return

  (_fzf_update_if_needed) &!
}

_fzf_auto_setup

# ============================================================================
# FZF Configuration
# ============================================================================
_fzf_setup_theme() {
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64 \
    --color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64 \
    --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
    --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
    --border=rounded \
    --border-label-pos=2 \
    --preview-window=border-rounded \
    --prompt='󰍉 ' \
    --marker='✓' \
    --pointer='▶' \
    --separator='─' \
    --scrollbar='│' \
    --layout=reverse \
    --info=inline"
}

_fzf_setup_commands() {
  if [[ $_HAS_FD -eq 1 ]]; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    return
  fi

  export FZF_DEFAULT_COMMAND='find . -type f 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d 2>/dev/null'
}

_fzf_setup_previews() {
  local bat_cmd=$(_get_bat_command)

  if [[ $_HAS_BAT -ne 1 ]] && [[ $_HAS_EZA -ne 1 ]]; then
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
    export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
    return
  fi

  if [[ $_HAS_BAT -eq 1 ]] && [[ $_HAS_EZA -ne 1 ]]; then
    export FZF_CTRL_T_OPTS="--preview '$bat_cmd --color=always --style=numbers --line-range :500 {}'"
    export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
    return
  fi

  if [[ $_HAS_BAT -ne 1 ]] && [[ $_HAS_EZA -eq 1 ]]; then
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
    return
  fi

  export FZF_CTRL_T_OPTS="--preview '$bat_cmd --color=always --style=numbers --line-range :500 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
}

[[ $_HAS_FZF -eq 1 ]] && [ -f ~/.fzf.zsh ] && {
  source ~/.fzf.zsh
  _fzf_setup_theme
  _fzf_setup_commands
  _fzf_setup_previews
}

# ============================================================================
# Lazy-load NVM (MASSIVE startup speedup)
# ============================================================================
export NVM_DIR="$HOME/.nvm"

# Placeholder function that loads NVM on first use
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Lazy node/npm/npx that trigger NVM load
node() { unset -f node; nvm; node "$@"; }
npm() { unset -f npm; nvm; npm "$@"; }
npx() { unset -f npx; nvm; npx "$@"; }

# ============================================================================
# Modern Tool Integration
# ============================================================================
_setup_zoxide() {
  [[ $_HAS_ZOXIDE -ne 1 ]] && return
  eval "$(zoxide init zsh)"
  alias cd="z"
}

_setup_eza() {
  [[ $_HAS_EZA -ne 1 ]] && return
  alias ls="eza --icons"
  alias ll="eza -l --icons --git"
  alias la="eza -la --icons --git"
  alias lt="eza --tree --level=2 --icons"
  alias lm="eza -la --icons --git --sort=modified"      # Sort by modified time
  alias lsize="eza -la --icons --git --sort=size"       # Sort by size
  alias tree="eza --tree --icons"                        # Tree view
}

_setup_bat() {
  [[ $_HAS_BAT -ne 1 ]] && return

  local bat_cmd=$(_get_bat_command)
  alias cat="$bat_cmd"
  alias bat="$bat_cmd"
  export BAT_THEME="$ZSHRC_BAT_THEME"
}

_setup_ripgrep() {
  [[ $_HAS_RIPGREP -ne 1 ]] && return
  alias grep="rg"

  # Only set config if file exists
  [[ -f "$HOME/.ripgreprc" ]] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
}

_setup_delta() {
  [[ $_HAS_DELTA -ne 1 ]] && return
  export DELTA_FEATURES="+side-by-side"
}

_setup_dust() {
  [[ $_HAS_DUST -ne 1 ]] && return
  alias du="dust"
}

_setup_procs() {
  [[ $_HAS_PROCS -ne 1 ]] && return
  alias ps="procs"
}

_setup_tldr() {
  [[ $_HAS_TLDR -ne 1 ]] && return
  alias help="tldr"
  _has_command tealdeer && alias tldr="tealdeer"
}

_setup_zoxide
_setup_eza
_setup_bat
_setup_ripgrep
_setup_delta
_setup_dust
_setup_procs
_setup_tldr

# ============================================================================
# Auto-ls after cd
# ============================================================================
chpwd() {
  emulate -L zsh
  if [[ $_HAS_EZA -eq 1 ]]; then
    eza -la --icons --git 2>/dev/null
  else
    ls -la
  fi
}

# ============================================================================
# Tool Status & Installation Helper
# ============================================================================
# Check what tools are installed and offer to install missing ones
check-tools() {
  echo "=== Shell Tools Status ==="
  echo ""

  local missing_count=0

  # Essential tools
  if [[ $_HAS_FZF -eq 1 ]]; then
    echo "✓ fzf (fuzzy finder)"
  else
    echo "✗ fzf (fuzzy finder) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_FD -eq 1 ]]; then
    echo "✓ fd (fast find)"
  else
    echo "✗ fd (fast find) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_BAT -eq 1 ]]; then
    echo "✓ bat (better cat)"
  else
    echo "✗ bat (better cat) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_EZA -eq 1 ]]; then
    echo "✓ eza (better ls)"
  else
    echo "✗ eza (better ls) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_ZOXIDE -eq 1 ]]; then
    echo "✓ zoxide (smart cd)"
  else
    echo "✗ zoxide (smart cd) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_NVIM -eq 1 ]]; then
    echo "✓ neovim (editor)"
  else
    echo "✗ neovim (editor) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_XCLIP -eq 1 ]]; then
    echo "✓ xclip (clipboard)"
  else
    echo "✗ xclip (clipboard) - MISSING"
    ((missing_count++))
  fi

  if [[ $_HAS_TMUX -eq 1 ]]; then
    echo "✓ tmux (multiplexer)"
  else
    echo "✗ tmux (multiplexer) - MISSING"
    ((missing_count++))
  fi

  echo ""
  echo "--- Bonus Tools (Optional) ---"
  echo ""

  local bonus_count=0

  if [[ $_HAS_RIPGREP -eq 1 ]]; then
    echo "✓ ripgrep (faster grep)"
  else
    echo "✗ ripgrep (faster grep) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_DELTA -eq 1 ]]; then
    echo "✓ delta (beautiful git diffs)"
  else
    echo "✗ delta (beautiful git diffs) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_LAZYGIT -eq 1 ]]; then
    echo "✓ lazygit (git UI)"
  else
    echo "✗ lazygit (git UI) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_TLDR -eq 1 ]]; then
    echo "✓ tldr/tealdeer (quick help)"
  else
    echo "✗ tldr/tealdeer (quick help) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_DUST -eq 1 ]]; then
    echo "✓ dust (visual disk usage)"
  else
    echo "✗ dust (visual disk usage) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_PROCS -eq 1 ]]; then
    echo "✓ procs (better ps)"
  else
    echo "✗ procs (better ps) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $_HAS_BTOP -eq 1 ]]; then
    echo "✓ btop (system monitor)"
  else
    echo "✗ btop (system monitor) - OPTIONAL"
    ((bonus_count++))
  fi

  if [[ $missing_count -eq 0 ]]; then
    echo ""
    echo "🎉 All essential tools are installed!"
    if [[ $bonus_count -gt 0 ]]; then
      echo "💡 Run 'install-bonus-tools' to install optional enhancements"
    else
      echo "🌟 All bonus tools installed too!"
    fi
    return 0
  fi

  echo ""
  echo "=== Installation Instructions ==="
  echo ""

  # Check if cargo is available
  local has_cargo=$(command -v cargo &> /dev/null && echo 1 || echo 0)

  if [[ $has_cargo -eq 1 ]]; then
    echo "✅ Rust/cargo detected - you'll get the latest versions!"
    echo ""
    echo "Recommended: Via cargo (latest versions):"
    local cargo_packages=()
    [[ $_HAS_FD -ne 1 ]] && cargo_packages+="fd-find "
    [[ $_HAS_BAT -ne 1 ]] && cargo_packages+="bat "
    [[ $_HAS_EZA -ne 1 ]] && cargo_packages+="eza "
    [[ $_HAS_ZOXIDE -ne 1 ]] && cargo_packages+="zoxide "

    if [[ ${#cargo_packages[@]} -gt 0 ]]; then
      echo "  cargo install ${cargo_packages[@]}"
    fi

    # System tools via apt
    local apt_packages=()
    [[ $_HAS_XCLIP -ne 1 ]] && apt_packages+="xclip "
    [[ $_HAS_TMUX -ne 1 ]] && apt_packages+="tmux "
    [[ $_HAS_NVIM -ne 1 ]] && apt_packages+="neovim "

    if [[ ${#apt_packages[@]} -gt 0 ]]; then
      echo ""
      echo "System tools via apt:"
      echo "  sudo apt install ${apt_packages[@]}"
    fi
  else
    echo "⚠️  cargo not found - you'll get older versions from apt"
    echo "   Install Rust for latest versions: https://rustup.rs"
    echo ""
    echo "Via apt (Ubuntu/Debian - older versions):"
    local apt_packages=()
    [[ $_HAS_FD -ne 1 ]] && apt_packages+="fd-find "
    [[ $_HAS_BAT -ne 1 ]] && apt_packages+="bat "
    [[ $_HAS_XCLIP -ne 1 ]] && apt_packages+="xclip "
    [[ $_HAS_TMUX -ne 1 ]] && apt_packages+="tmux "
    [[ $_HAS_NVIM -ne 1 ]] && apt_packages+="neovim "
    [[ $_HAS_ZOXIDE -ne 1 ]] && apt_packages+="zoxide "

    if [[ ${#apt_packages[@]} -gt 0 ]]; then
      echo "  sudo apt install ${apt_packages[@]}"
      [[ $_HAS_FD -ne 1 ]] && echo "  ln -s \$(which fdfind) ~/.local/bin/fd  # Create fd symlink"
    fi
  fi

  if [[ $_HAS_FZF -ne 1 ]]; then
    echo ""
    echo "fzf (always latest from GitHub):"
    echo "  Auto-installs on next shell reload, or run:"
    echo "  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
  fi

  echo ""
  echo "💡 Run 'install-tools' to install missing tools automatically"
}

# Auto-installer for missing tools
install-tools() {
  echo "=== Installing Missing Tools ==="
  echo ""
  echo "💡 Tip: cargo (Rust) provides newer versions than apt"
  echo ""

  local missing=0
  local has_cargo=$(command -v cargo &> /dev/null && echo 1 || echo 0)

  # Install fzf first (always latest via git)
  if [[ $_HAS_FZF -ne 1 ]]; then
    echo "📦 Installing fzf (latest from GitHub)..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    missing=1
  fi

  # Prefer cargo for tools that benefit from latest versions
  if [[ $has_cargo -eq 1 ]]; then
    local cargo_packages=()
    [[ $_HAS_FD -ne 1 ]] && cargo_packages+=(fd-find)
    [[ $_HAS_BAT -ne 1 ]] && cargo_packages+=(bat)
    [[ $_HAS_EZA -ne 1 ]] && cargo_packages+=(eza)
    [[ $_HAS_ZOXIDE -ne 1 ]] && cargo_packages+=(zoxide)

    if [[ ${#cargo_packages[@]} -gt 0 ]]; then
      echo "📦 Installing via cargo (latest versions): ${cargo_packages[@]}"
      cargo install "${cargo_packages[@]}"
      missing=1
    fi
  else
    echo "⚠️  cargo not found. Install Rust from https://rustup.rs for latest tool versions"
    echo "   Falling back to apt (older versions)..."
    echo ""
  fi

  # Fall back to apt for tools not installed via cargo and system tools
  if command -v apt &> /dev/null; then
    local apt_packages=()

    # Only use apt if cargo didn't install or isn't available
    if [[ $has_cargo -ne 1 ]]; then
      [[ $_HAS_FD -ne 1 ]] && apt_packages+=(fd-find)
      [[ $_HAS_BAT -ne 1 ]] && apt_packages+=(bat)
      [[ $_HAS_ZOXIDE -ne 1 ]] && apt_packages+=(zoxide)
    fi

    # System tools always via apt
    [[ $_HAS_XCLIP -ne 1 ]] && apt_packages+=(xclip)
    [[ $_HAS_TMUX -ne 1 ]] && apt_packages+=(tmux)
    [[ $_HAS_NVIM -ne 1 ]] && apt_packages+=(neovim)

    if [[ ${#apt_packages[@]} -gt 0 ]]; then
      echo "📦 Installing via apt: ${apt_packages[@]}"
      sudo apt update && sudo apt install -y "${apt_packages[@]}"

      # Create fd symlink if installed via apt
      if [[ $_HAS_FD -ne 1 ]] && command -v fdfind &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" ~/.local/bin/fd
        echo "✓ Created fd symlink"
      fi
      missing=1
    fi
  fi

  if [[ $missing -eq 1 ]]; then
    echo ""
    echo "✅ Installation complete! Reload your shell with: exec zsh"
    echo ""
    echo "Installed versions:"
    command -v fzf &> /dev/null && echo "  fzf: $(fzf --version 2>&1 | head -1)"
    command -v fd &> /dev/null && echo "  fd: $(fd --version 2>&1 | head -1)"
    command -v bat &> /dev/null && echo "  bat: $(bat --version 2>&1 | head -1)"
    command -v eza &> /dev/null && echo "  eza: $(eza --version 2>&1 | head -1)"
    command -v zoxide &> /dev/null && echo "  zoxide: $(zoxide --version 2>&1 | head -1)"
  else
    echo "✅ All tools already installed!"
  fi
}

# Fix locale issues (common in WSL)
fix-locale() {
  echo "=== Fixing Locale Settings ==="
  echo ""

  # Check if locale is already generated
  if locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    echo "✅ en_US.UTF-8 locale already installed"
    return 0
  fi

  echo "📦 Generating en_US.UTF-8 locale..."
  echo ""
  echo "This requires sudo access and will:"
  echo "  1. Uncomment en_US.UTF-8 in /etc/locale.gen"
  echo "  2. Run locale-gen to generate the locale"
  echo ""

  # Generate locale
  sudo sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen 2>/dev/null
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8

  echo ""
  echo "✅ Locale fixed! Reload your shell: exec zsh"
}

# Install bonus/extended tools
install-bonus-tools() {
  echo "=== Installing Bonus CLI Tools ==="
  echo ""
  echo "These tools enhance your workflow with better alternatives:"
  echo "  • ripgrep (rg)    - Faster grep with better output"
  echo "  • delta           - Beautiful git diffs"
  echo "  • lazygit         - Interactive git UI"
  echo "  • tealdeer (tldr) - Quick command examples"
  echo "  • dust            - Visual disk usage"
  echo "  • procs           - Better process viewer"
  echo "  • btop            - Beautiful system monitor"
  echo ""

  local has_cargo=$(command -v cargo &> /dev/null && echo 1 || echo 0)

  if [[ $has_cargo -ne 1 ]]; then
    echo "❌ cargo not found. Install Rust first: https://rustup.rs"
    return 1
  fi

  local tools=()
  [[ $_HAS_RIPGREP -ne 1 ]] && tools+=(ripgrep)
  [[ $_HAS_DELTA -ne 1 ]] && tools+=(git-delta)
  [[ $_HAS_LAZYGIT -ne 1 ]] && echo "⚠️  lazygit requires manual install (Go-based): https://github.com/jesseduffield/lazygit"
  [[ $_HAS_TLDR -ne 1 ]] && tools+=(tealdeer)
  [[ $_HAS_DUST -ne 1 ]] && tools+=(du-dust)
  [[ $_HAS_PROCS -ne 1 ]] && tools+=(procs)
  [[ $_HAS_BTOP -ne 1 ]] && tools+=(btop)

  if [[ ${#tools[@]} -gt 0 ]]; then
    echo "📦 Installing via cargo: ${tools[@]}"
    cargo install "${tools[@]}"

    # Configure delta for git if installed
    if [[ $_HAS_DELTA -ne 1 ]] && command -v delta &> /dev/null; then
      echo ""
      echo "🎨 Configuring git to use delta..."
      git config --global core.pager "delta"
      git config --global interactive.diffFilter "delta --color-only"
      git config --global delta.navigate true
      git config --global delta.side-by-side true
      git config --global delta.line-numbers true
      git config --global merge.conflictstyle diff3
      git config --global diff.colorMoved default
    fi

    # Initialize tldr cache
    if [[ $_HAS_TLDR -ne 1 ]] && command -v tealdeer &> /dev/null; then
      echo ""
      echo "📚 Updating tldr cache..."
      tealdeer --update
    fi

    echo ""
    echo "✅ Bonus tools installed! Reload your shell: exec zsh"
  else
    echo "✅ All bonus tools already installed!"
  fi
}

# ============================================================================
# Aliases
# ============================================================================
alias v="nvim"
alias vim="nvim"
alias c="clear"
alias reload="source ~/.zshrc"

# Git shortcuts
alias gs="git status"
alias gst="git status -sb"                                    # Short status with branch
alias gd="git diff"
alias gdw="git diff --color-words"                            # Word-level diff
alias ga="git add"
alias gaa="git add --all"                                     # Add all changes
alias gc="git commit"
alias gcm="git commit -m"                                     # Commit with message
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline --graph --decorate"
alias glog="git log --oneline --graph --decorate --all"      # All branches
alias gco="git checkout"
alias gcb="git checkout -b"                                   # Create and checkout branch
alias gb="git branch"
alias gba="git branch -a"                                     # All branches including remote

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# List processes
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# ============================================================================
# Custom FZF History Widget (populate without executing)
# ============================================================================
fzf-history-widget-accept() {
  local selected
  selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | \
    fzf --height 40% --reverse --tiebreak=index --bind=ctrl-r:toggle-sort \
    --query="${LBUFFER}" \
    --prompt="History > ")

  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
    zle redisplay
  fi
}
zle -N fzf-history-widget-accept

# ============================================================================
# Keybindings
# ============================================================================
# Custom widget for tmux-sessionizer (execute directly)
tmux-sessionizer-widget() {
  BUFFER="~/.local/scripts/tmux-sessionizer"
  zle accept-line
}
zle -N tmux-sessionizer-widget
bindkey '^f' tmux-sessionizer-widget

# Fuzzy git branch checkout (Ctrl+G)
fzf-git-branch-widget() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return
  fi

  local branch
  branch=$(git branch -a | grep -v HEAD | sed 's/^[* ]*//' | sed 's#remotes/origin/##' | sort -u | fzf --height 40% --reverse --prompt="Git Branch > ")

  if [[ -n "$branch" ]]; then
    BUFFER="git checkout $branch"
    zle accept-line
  fi
}
zle -N fzf-git-branch-widget
bindkey '^g' fzf-git-branch-widget

# Additional useful bindings (if tools exist)
bindkey '^r' fzf-history-widget-accept      # Ctrl-r: fuzzy history search (populate without executing)

# history-substring-search plugin bindings
bindkey '^[[A' history-substring-search-up      # Up arrow
bindkey '^[[B' history-substring-search-down    # Down arrow
bindkey '^P' history-substring-search-up        # Ctrl-p
bindkey '^N' history-substring-search-down      # Ctrl-n

# Additional productivity keybindings
bindkey '\e.' insert-last-word                  # Alt+. insert last argument
bindkey '^U' backward-kill-line                 # Ctrl+U delete to beginning
bindkey '\e^?' backward-kill-word               # Alt+Backspace delete word backward

# ============================================================================
# FZF Smart Selector - Helper Functions
# ============================================================================
_fzf_build_find_command() {
  [[ $_HAS_FD -eq 1 ]] && echo "fd --type f --type d --hidden --follow --exclude .git" || echo "find . -type f -o -type d 2>/dev/null"
}

_fzf_build_preview_command() {
  local bat_cmd=$(_get_bat_command)

  if [[ $_HAS_EZA -eq 1 ]] && [[ $_HAS_BAT -eq 1 ]]; then
    echo "[[ -d {} ]] && eza --tree --color=always {} | head -200 || $bat_cmd --color=always --style=numbers --line-range :500 {}"
  elif [[ $_HAS_EZA -eq 1 ]]; then
    echo "[[ -d {} ]] && eza --tree --color=always {} | head -200 || cat {}"
  elif [[ $_HAS_BAT -eq 1 ]]; then
    echo "[[ -d {} ]] && ls -la {} || $bat_cmd --color=always --style=numbers --line-range :500 {}"
  else
    echo "[[ -d {} ]] && ls -la {} || cat {}"
  fi
}

_fzf_build_directory_actions() {
  local actions="cd into directory\nopen in file manager\ncopy path"
  [[ $_HAS_EZA -eq 1 ]] && actions="$actions\nshow tree"
  [[ $_HAS_TMUX -eq 1 ]] && actions="$actions\nopen in new tmux pane"
  echo "$actions"
}

_fzf_build_file_actions() {
  local actions="open file\nshow content\ncopy path"
  [[ $_HAS_NVIM -eq 1 ]] && actions="edit file\n$actions"
  [[ $_HAS_XCLIP -eq 1 ]] && actions="$actions\ncopy content"
  echo "$actions\ndelete file"
}

_fzf_copy_to_clipboard() {
  local content="$1"
  local message="$2"

  if [[ $_HAS_XCLIP -eq 1 ]]; then
    echo -n "$content" | xclip -selection clipboard && echo "$message"
  else
    echo "$message (xclip not installed for clipboard support)"
  fi
}

_fzf_show_tree() {
  local dir="$1"

  if [[ $_HAS_EZA -eq 1 ]]; then
    eza --tree --color=always "$dir" | less -R
  else
    tree "$dir" 2>/dev/null || find "$dir" -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g" | less
  fi
}

_fzf_handle_directory_action() {
  local selected="$1"
  local action="$2"

  case "$action" in
    "cd into directory")
      cd "$selected"
      ;;
    "open in file manager")
      xdg-open "$selected" &> /dev/null &
      ;;
    "show tree")
      _fzf_show_tree "$selected"
      ;;
    "copy path")
      _fzf_copy_to_clipboard "$selected" "Path copied: $selected"
      ;;
    "open in new tmux pane")
      [[ $_HAS_TMUX -eq 1 ]] && tmux split-window -h "cd '$selected' && exec zsh"
      ;;
  esac

  zle reset-prompt
}

_fzf_handle_file_action() {
  local selected="$1"
  local action="$2"
  local bat_cmd=$(_get_bat_command)

  case "$action" in
    "edit file")
      ${EDITOR:-vi} "$selected"
      ;;
    "open file")
      xdg-open "$selected" &> /dev/null &
      ;;
    "show content")
      [[ $_HAS_BAT -eq 1 ]] && $bat_cmd --color=always --style=full "$selected" | less -R || less "$selected"
      ;;
    "copy path")
      _fzf_copy_to_clipboard "$selected" "Path copied: $selected"
      ;;
    "copy content")
      [[ $_HAS_XCLIP -eq 1 ]] && cat "$selected" | xclip -selection clipboard && echo "Content copied from: $selected" || echo "xclip not installed"
      ;;
    "delete file")
      echo -n "Delete $selected? (y/N) " && read -q && rm "$selected" && echo "\nDeleted: $selected"
      ;;
  esac

  zle reset-prompt
}

_fzf_select_and_preview() {
  local find_cmd=$(_fzf_build_find_command)
  local preview_cmd=$(_fzf_build_preview_command)

  eval "$find_cmd" | fzf \
    --preview "$preview_cmd" \
    --header 'Enter: Action Menu | Ctrl-o: Open | Ctrl-e: Edit | Ctrl-d: CD' \
    --bind 'ctrl-o:execute(xdg-open {} &> /dev/null)' \
    --bind 'ctrl-e:execute($EDITOR {})' \
    --bind 'ctrl-d:execute(echo cd {})'
}

_fzf_show_action_menu() {
  local selected="$1"

  if [[ -d "$selected" ]]; then
    local actions=$(_fzf_build_directory_actions)
    local action=$(echo "$actions" | fzf --height $ZSHRC_FZF_MENU_HEIGHT --header "Directory: $selected" --prompt "Action: ")
    [[ -n "$action" ]] && _fzf_handle_directory_action "$selected" "$action"
  else
    local actions=$(_fzf_build_file_actions)
    local action=$(echo "$actions" | fzf --height $ZSHRC_FZF_MENU_HEIGHT --header "File: $selected" --prompt "Action: ")
    [[ -n "$action" ]] && _fzf_handle_file_action "$selected" "$action"
  fi
}

# Main function - clean and simple
fzf-smart-select() {
  [[ $_HAS_FZF -ne 1 ]] && echo "fzf not installed. Run: install-tools" && return 1

  local selected=$(_fzf_select_and_preview)
  [[ -n "$selected" ]] && _fzf_show_action_menu "$selected"
}

zle -N fzf-smart-select
bindkey '^t' fzf-smart-select

bindkey '^[c' fzf-cd-widget          # Alt-c: fuzzy directory change

# ============================================================================
# Appearance & Autosuggestions
# ============================================================================

# Autosuggestions styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"  # Subtle gray (purple was unreadable)

# Autosuggestion strategy: prioritize history, then completion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Faster autosuggestions (async mode)
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Accept autosuggestion with Ctrl+Space (in addition to Right Arrow)
bindkey '^ ' autosuggest-accept

# Accept just one word with Ctrl+Right Arrow
bindkey '^[[1;5C' forward-word

# Clear suggestion with Ctrl+x
bindkey '^x' autosuggest-clear

eval "$(starship init zsh)"

# ============================================================================
# Productivity Enhancements
# ============================================================================
[ -f "$HOME/.zsh_productivity" ] && source "$HOME/.zsh_productivity"

# ============================================================================
# Interactive Cheat Sheets
# ============================================================================
[ -f "$HOME/.zsh_cheatsheet" ] && source "$HOME/.zsh_cheatsheet"

# ============================================================================
# Local Environment
# ============================================================================
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# ============================================================================
# Startup Tool Check
# ============================================================================
# Show missing tools message on startup (once per day)
_check_missing_tools() {
  local check_file="$HOME/.zsh_tools_check"
  local missing_tools=()

  # Only check once per day
  if [[ -f "$check_file" ]]; then
    local last_check=$(cat "$check_file")
    local now=$(date +%s)
    local hours_since_check=$(( (now - last_check) / 3600 ))

    if [[ $hours_since_check -lt 24 ]]; then
      return 0
    fi
  fi

  # Check for missing tools
  [[ $_HAS_FZF -ne 1 ]] && missing_tools+=("fzf")
  [[ $_HAS_FD -ne 1 ]] && missing_tools+=("fd")
  [[ $_HAS_BAT -ne 1 ]] && missing_tools+=("bat")
  [[ $_HAS_EZA -ne 1 ]] && missing_tools+=("eza")
  [[ $_HAS_ZOXIDE -ne 1 ]] && missing_tools+=("zoxide")
  [[ $_HAS_NVIM -ne 1 ]] && missing_tools+=("nvim")
  [[ $_HAS_XCLIP -ne 1 ]] && missing_tools+=("xclip")
  [[ $_HAS_TMUX -ne 1 ]] && missing_tools+=("tmux")

  # Show message if tools are missing
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Missing recommended tools: ${missing_tools[*]}"
    echo "   Run 'check-tools' to see details or 'install-tools' to install them"
    echo ""
  fi

  # Update check timestamp
  date +%s > "$check_file"
}

# Run check in background to avoid slowing shell startup
_check_missing_tools &!

# ============================================================================
# Direnv - Auto-load .envrc files
# ============================================================================
_has_command direnv && eval "$(direnv hook zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# bun completions
[ -s "/home/barilc/.bun/_bun" ] && source "/home/barilc/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
