# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## ⚠️ Privacy Notice

This repository contains **sanitized** configuration files safe for public sharing:
- ✅ No personal information (names, emails, paths)
- ✅ No secrets, tokens, or credentials
- ✅ Uses `$HOME` instead of hardcoded paths
- ✅ Git config uses placeholders (YOU MUST UPDATE THESE!)

**Before using:** Update `git/.gitconfig` with your own name and email!

## Structure

```
dotfiles/
├── zsh/              # Zsh configuration
│   ├── .zshrc
│   ├── .zsh_productivity
│   └── .zsh_cheatsheet
├── starship/         # Starship prompt configuration
│   └── .config/starship.toml
├── tmux/             # Tmux configuration
│   └── .tmux.conf
├── git/              # Git configuration
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/             # Neovim configuration (placeholder)
└── install.sh        # Bootstrap script
```

## Quick Start

### First Time Setup

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installer (installs stow and sets up symlinks)
./install.sh
```

### Manual Installation

```bash
# Install GNU Stow
sudo apt install stow

# Stow individual packages
cd ~/dotfiles
stow zsh       # Creates ~/.zshrc, ~/.zsh_productivity, ~/.zsh_cheatsheet
stow starship  # Creates ~/.config/starship.toml
stow tmux      # Creates ~/.tmux.conf
stow git       # Creates ~/.gitconfig and ~/.gitignore_global
```

## What is GNU Stow?

Stow creates symlinks from `~/dotfiles/PACKAGE/*` to `~/`.

Example:
```
~/dotfiles/zsh/.zshrc  →  symlinks to  →  ~/.zshrc
```

This keeps your actual configs in the git repo while making them available in their expected locations.

## Managing Dotfiles

### Add a new config

```bash
cd ~/dotfiles

# Create package directory
mkdir -p newpackage

# Move your config into it (maintaining directory structure)
mv ~/.config/something newpackage/.config/

# Stow it
stow newpackage
```

### Update configs

Just edit the files in `~/dotfiles/PACKAGE/` - they're symlinked, so changes are immediate!

### Remove a package

```bash
stow -D zsh  # Removes ~/.zshrc symlink
```

### Re-stow after updates

```bash
stow -R zsh  # Removes old symlinks, creates new ones
```

## Sync to Another Machine

```bash
# On new machine
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Backup Workflow

```bash
cd ~/dotfiles

# Make changes to your configs
vim zsh/.zshrc

# Commit and push
git add .
git commit -m "Update zsh config"
git push
```

## Features

### Zsh Configuration
- Modern CLI tools (fzf, eza, bat, zoxide, ripgrep)
- Tokyo Night theme for fzf
- Smart file/directory selector (Ctrl-t)
- Auto-updating fzf
- Lazy-loaded NVM for fast startup
- Comprehensive tool checking and installation helpers

### Git Configuration
- Sensible defaults
- Delta for beautiful diffs
- Global gitignore

### Tmux Configuration
- Ergonomic keybindings
- Status bar customization

### Neovim Configuration
- [Your nvim config details]

## Troubleshooting

### Conflicts
If files already exist at `~/`:
```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup

# Then stow
stow zsh
```

### Check what would be created
```bash
stow -n zsh  # Dry run, shows what would happen
```

### Unstow everything
```bash
stow -D */  # Removes all symlinks
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `stow zsh` | Create symlinks for zsh package |
| `stow -D zsh` | Remove symlinks for zsh package |
| `stow -R zsh` | Restow (remove + create) |
| `stow -n zsh` | Dry run (shows what would happen) |
| `stow */` | Stow all packages |
| `stow -D */` | Unstow all packages |

## Tips

1. **Test first**: Use `stow -n` to see what would happen
2. **Backup**: Keep backups of configs before stowing
3. **Commit often**: Small, frequent commits are easier to track
4. **Document**: Add comments explaining why you made changes
5. **Machine-specific**: Use separate branches or files for machine-specific configs

## Links

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Managing Dotfiles with Stow](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
