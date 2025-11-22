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

backup_existing_files() {
    info "Checking for existing configuration files..."

    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local files_backed_up=0

    # Check for files that would conflict
    local files_to_check=(
        "$HOME/.zshrc"
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
    local packages=(zsh nvim tmux git)

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
    echo "  4. Initialize git repository (if not already done):"
    echo -e "     ${BLUE}cd ~/dotfiles && git init && git add . && git commit -m \"Initial commit\"${NC}"
    echo ""
    echo "  5. Push to GitHub:"
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
    backup_existing_files
    install_dotfiles
    show_next_steps
}

main "$@"
