#!/usr/bin/env bash
#
# Bootstrap script for dotfiles installation
# Usage: curl -sSL https://raw.githubusercontent.com/hydromel-project/dotfiles/main/bootstrap.sh | bash
#

set -e

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Git is required but not installed. Please install git first."
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "curl is required but not installed. Please install curl first."
    exit 1
fi

# Clone dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    info "Dotfiles directory already exists. Updating..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    info "Cloning dotfiles repository..."
    git clone https://github.com/hydromel-project/dotfiles.git "$DOTFILES_DIR"
fi

# Make install script executable
chmod +x "$DOTFILES_DIR/install.sh"

# Run the full installation script
cd "$DOTFILES_DIR"
./install.sh

success "Bootstrap complete!"