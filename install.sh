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

install_dependencies() {
    local packages_to_install=()
    
    info "Checking core dependencies..."
    
    # Check for curl or wget
    if ! command_exists curl && ! command_exists wget; then
        packages_to_install+=("curl")
    fi
    
    # Check for zsh
    if ! command_exists zsh; then
        packages_to_install+=("zsh")
    fi
    
    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        success "All core dependencies already installed"
        return 0
    fi
    
    info "Installing dependencies: ${packages_to_install[*]}"

    if command_exists apt; then
        sudo apt update && sudo apt install -y "${packages_to_install[@]}"
    elif command_exists brew; then
        brew install "${packages_to_install[@]}"
    elif command_exists pacman; then
        sudo pacman -S --noconfirm "${packages_to_install[@]}"
    elif command_exists dnf; then
        sudo dnf install -y "${packages_to_install[@]}"
    elif command_exists yum; then
        sudo yum install -y "${packages_to_install[@]}"
    else
        error "Could not detect package manager. Please install manually: ${packages_to_install[*]}"
        exit 1
    fi

    success "Core dependencies installed"
}

install_zsh() {
    if command_exists zsh; then
        success "Zsh already installed"
        return 0
    fi

    # This should be handled by install_dependencies now
    error "Zsh should have been installed by install_dependencies. Something went wrong."
    exit 1
}

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh already installed"
        return 0
    fi

    info "Installing Oh My Zsh..."
    
    # Download and install Oh My Zsh
    if command_exists curl; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command_exists wget; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        error "curl or wget is required to install Oh My Zsh"
        exit 1
    fi

    success "Oh My Zsh installed"
}

change_default_shell() {
    local current_shell="$SHELL"
    local zsh_path
    
    # Get zsh path
    zsh_path=$(which zsh)
    
    if [[ "$current_shell" == "$zsh_path" ]]; then
        success "Zsh is already the default shell"
        return 0
    fi

    info "Changing default shell to Zsh..."
    
    # Add zsh to /etc/shells if not already there
    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change default shell
    if command_exists chsh; then
        sudo chsh -s "$zsh_path" "$USER"
        success "Default shell changed to Zsh"
        warning "You'll need to restart your terminal or run 'exec zsh' to use the new shell"
    else
        warning "chsh not available. Please manually set Zsh as your default shell"
    fi
}

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
    elif command_exists dnf; then
        sudo dnf install -y stow
    elif command_exists yum; then
        sudo yum install -y stow
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
    echo "What was installed:"
    echo -e "  ✓ Zsh shell with Oh My Zsh framework"
    echo -e "  ✓ Neovim 0.12 with comprehensive configuration"
    echo -e "  ✓ Starship prompt with local IP and machine name"
    echo -e "  ✓ GNU Stow for dotfiles management"
    echo -e "  ✓ All configuration files properly linked"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Start using Zsh (if not already active):"
    echo -e "     ${BLUE}exec zsh${NC}"
    echo ""
    echo "  2. Install recommended development tools:"
    echo -e "     ${BLUE}install-tools${NC}"
    echo -e "     ${BLUE}install-bonus-tools${NC}"
    echo ""
    echo "  3. Fix locale if needed:"
    echo -e "     ${BLUE}fix-locale${NC}"
    echo ""
    echo "  4. Install Neovim stable version (optional):"
    echo -e "     ${BLUE}NVIM_STABLE=true ./install.sh${NC}"
    echo ""
    echo "Useful commands:"
    echo -e "  ${BLUE}check-tools${NC}     - See what tools are installed/missing"
    echo -e "  ${BLUE}<Space>tw${NC}      - Trim whitespace in Neovim"
    echo -e "  ${BLUE}<Space>e${NC}       - File explorer in Neovim"
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

    # Install core dependencies first (curl/wget, zsh)
    install_dependencies
    install_stow
    generate_locale
    
    # Install development tools
    install_nvim
    
    # Install Oh My Zsh (after zsh and curl/wget are installed)
    install_ohmyzsh
    
    # Setup dotfiles
    backup_existing_files
    install_dotfiles
    
    # Change shell (after everything is set up)
    change_default_shell
    
    show_next_steps
}

main "$@"
