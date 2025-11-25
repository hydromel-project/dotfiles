#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Installs GNU Stow and symlinks all configurations

set -e  # Exit on error

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Script directory
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#================================================================================
# Helper Functions
#================================================================================

info() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

#================================================================================
# Installation Functions
#================================================================================

install_stow() {
    if command_exists stow; then
        success "GNU Stow already installed"
        return 0
    fi

    info "Installing GNU Stow..."

    if command_exists apt; then
        sudo apt update && sudo apt install -y stow
    elif command_exists brew; then
        brew install stow
    elif command_exists pacman; then
        sudo pacman -S stow
    else
        error "Could not detect package manager. Please install GNU Stow manually."
        exit 1
    fi

    success "GNU Stow installed"
}

generate_locale() {
    info "Checking locale configuration..."

    if locale -a | grep -q "en_US.utf8\|en_US.UTF-8"; then
        success "UTF-8 locale already available"
        return 0
    fi

    info "Generating en_US.UTF-8 locale..."
    
    if command_exists apt; then
        # Ubuntu/Debian
        if [[ -f /etc/locale.gen ]]; then
            sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
            sudo locale-gen
            success "Generated en_US.UTF-8 locale"
        else
            warning "Could not find /etc/locale.gen, skipping locale generation"
            warning "You may need to run: sudo locale-gen en_US.UTF-8"
        fi
    elif command_exists pacman; then
        # Arch Linux
        if [[ -f /etc/locale.gen ]]; then
            sudo sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
            sudo locale-gen
            success "Generated en_US.UTF-8 locale"
        else
            warning "Could not find /etc/locale.gen, skipping locale generation"
        fi
    else
        warning "Unsupported system for automatic locale generation"
        warning "Your shell configuration will use C.UTF-8 locale instead"
        warning "To manually generate en_US.UTF-8:"
        warning "  1. Edit /etc/locale.gen and uncomment 'en_US.UTF-8 UTF-8'"
        warning "  2. Run: sudo locale-gen"
    fi
}

install_nvim() {
    info "Checking Neovim installation..."

    # Check for NVIM_STABLE environment variable to install stable version (default is nightly)
    local use_stable_version="${NVIM_STABLE:-false}"
    local target_version=""
    local nvim_url=""
    local nvim_file=""
    local version_name=""

    if [[ "$use_stable_version" == "true" ]]; then
        # Get latest stable version from GitHub
        target_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        version_name="$target_version (stable)"
        
        if [[ -z "$target_version" ]]; then
            error "Could not fetch latest Neovim version"
            return 1
        fi
        
        info "Installing Neovim stable version ($target_version)..."
    else
        target_version="nightly"
        version_name="0.12.0-dev (nightly)"
        info "Installing Neovim development version (0.12.0-dev)..."
    fi

    local current_version=""
    if command_exists nvim; then
        current_version=$(nvim --version | head -n1 | awk '{print $2}')
        
        if [[ "$use_stable_version" == "true" ]]; then
            if [[ "v$current_version" == "$target_version" ]] || [[ "$current_version" == "$target_version" ]]; then
                success "Neovim $version_name already installed"
                return 0
            else
                warning "Found Neovim $current_version, upgrading to $version_name..."
            fi
        else
            if [[ "$current_version" =~ ^v0\.12\.0-dev ]]; then
                success "Neovim $version_name already installed"
                return 0
            else
                warning "Found Neovim $current_version, upgrading to $version_name..."
            fi
        fi
    fi

    info "Installing Neovim $version_name..."

    case "$(uname -m)" in
        x86_64)
            if [[ "$use_stable_version" == "true" ]]; then
                nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                nvim_file="nvim-linux64.tar.gz"
            else
                nvim_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
                nvim_file="nvim-linux-x86_64.tar.gz"
            fi
            ;;
        aarch64|arm64)
            if [[ "$use_stable_version" == "true" ]]; then
                nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                nvim_file="nvim-linux64.tar.gz"
                warning "Using x64 binary for ARM64 - stable releases don't have native ARM64"
            else
                nvim_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.tar.gz"
                nvim_file="nvim-linux-arm64.tar.gz"
            fi
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            warning "Please install Neovim manually from: https://github.com/neovim/neovim/releases"
            return 1
            ;;
    esac

    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    info "Downloading Neovim $version_name..."
    if ! curl -L -o "$nvim_file" "$nvim_url"; then
        error "Failed to download Neovim"
        rm -rf "$temp_dir"
        return 1
    fi

    info "Extracting Neovim..."
    if ! tar xzf "$nvim_file"; then
        error "Failed to extract Neovim archive"
        rm -rf "$temp_dir"
        return 1
    fi

    info "Installing Neovim to ~/.local/..."
    mkdir -p "$HOME/.local"
    
    # Different extraction paths for different releases
    if [[ "$use_stable_version" == "true" ]]; then
        rsync -av nvim-linux64/ "$HOME/.local/"
    else
        rsync -av nvim-linux-*/ "$HOME/.local/"
    fi

    # Clean up
    rm -rf "$temp_dir"

    # Verify installation
    if command_exists nvim; then
        local installed_version=$(nvim --version | head -n1)
        success "Neovim $version_name installed successfully"
        success "Version: $installed_version"
        success "Location: $HOME/.local/bin/nvim"
        success "Make sure $HOME/.local/bin is in your PATH"
    else
        error "Neovim installation verification failed"
        return 1
    fi
}

backup_existing_files() {
    info "Checking for existing configuration files..."

    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local files_backed_up=0

    # Check for files that would conflict
    local files_to_check=(
        "$HOME/.zshrc"
        "$HOME/.config/starship.toml"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
    )

    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
            if [[ $files_backed_up -eq 0 ]]; then
                mkdir -p "$backup_dir"
                warning "Found existing files. Creating backup in: $backup_dir"
            fi

            mv "$file" "$backup_dir/"
            ((files_backed_up++))
            warning "Backed up: $(basename "$file")"
        fi
    done

    if [[ $files_backed_up -gt 0 ]]; then
        success "Backed up $files_backed_up file(s)"
    else
        success "No conflicting files found"
    fi
}

stow_package() {
    local package="$1"

    if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
        warning "Package '$package' not found, skipping"
        return 1
    fi

    info "Stowing $package..."

    cd "$DOTFILES_DIR"

    if stow -R "$package" 2>&1 | grep -q "conflict"; then
        error "Conflict detected for package: $package"
        error "Run: stow -n $package to see details"
        return 1
    fi

    stow -R "$package"
    success "Stowed $package"
}

install_dotfiles() {
    local packages=(zsh starship tmux git nvim)

    info "Installing dotfiles..."

    for package in "${packages[@]}"; do
        stow_package "$package" || warning "Failed to stow $package"
    done

    success "Dotfiles installation complete!"
}

show_next_steps() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Dotfiles installed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Reload your shell:"
    echo -e "     ${BLUE}exec zsh${NC}"
    echo ""
    echo "  2. Install recommended tools:"
    echo -e "     ${BLUE}install-tools${NC}"
    echo -e "     ${BLUE}install-bonus-tools${NC}"
    echo ""
    echo "  3. Fix locale if needed:"
    echo -e "     ${BLUE}fix-locale${NC}"
    echo ""
    echo "  4. Install Neovim stable version (optional):"
    echo -e "     ${BLUE}NVIM_STABLE=true ./install.sh${NC}"
    echo ""
    echo "  5. Initialize git repository (if not already done):"
    echo -e "     ${BLUE}cd ~/dotfiles && git init && git add . && git commit -m \"Initial commit\"${NC}"
    echo ""
    echo "  6. Push to GitHub:"
    echo -e "     ${BLUE}gh repo create dotfiles --private --source=. --push${NC}"
    echo "     ${BLUE}# OR manually: git remote add origin <your-repo-url> && git push -u origin main${NC}"
    echo ""
    echo "Your backups (if any) are in: ~/.dotfiles_backup_*"
    echo ""
}

#================================================================================
# Main
#================================================================================

main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Dotfiles Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    install_stow
    generate_locale
    install_nvim
    backup_existing_files
    install_dotfiles
    show_next_steps
}

main "$@"
