# Shell Productivity Quick Reference

## 🚀 Quick Wins for Your Pain Points

### Problem: Repetitive Commands

| Old Way | New Way | Benefit |
|---------|---------|---------|
| `cd /long/path && ls` | `cdl /long/path` | Combines cd + ls |
| `mkdir foo && cd foo` | `mkcd foo` | One command |
| `git add -A && git commit -m "msg"` | `gac "msg"` | Save 15 keystrokes |
| `git add -A && git commit && git push` | `gacp "msg"` | Complete workflow in one |

### Problem: Finding Things

| Task | Command | Example |
|------|---------|---------|
| Find file by name | `ff <pattern>` | `ff package.json` |
| Find AND edit | `fe <pattern>` | `fe config` (opens fzf) |
| Search file contents | `search <text>` | `search "TODO"` |
| Search history | `hist <term>` | `hist docker` |

### Problem: Context Switching

```bash
# Bookmark your projects once
cd ~/work/my-app
padd myapp

cd ~/personal/blog
padd blog

# Now jump instantly (with fuzzy search)
p  # Opens fuzzy finder, type 'my' → Enter

# List all bookmarks
plist

# Remove bookmark
prem
```

---

## 📚 Complete Command Reference

### Navigation (Faster Movement)

```bash
..2                    # Go up 2 directories
..3                    # Go up 3 directories
groot                  # Jump to git repository root
mkcd newdir            # Create + cd in one
cdl ~/code             # cd + ls combined
```

### Search & Find (Stop Wasting Time)

```bash
# Find files
ff config              # Case-insensitive file search
fe todo                # Find file + edit with fzf preview
fd_dir src             # Find directories only

# Search content
search "function"      # Grep with context (3 lines)
search "bug" src/      # Search in specific directory
hist git               # Search command history

# Processes
psgrep node            # Find process by name
killp node             # Kill process (interactive)
```

### Git Workflow (Less Typing)

```bash
# Quick commits
gac "fix bug"          # git add -A && commit
gacp "new feature"     # add, commit, push
gca                    # Amend last commit (no edit)

# Undo & cleanup
gundo                  # Undo last commit (keep changes)
gclean                 # Delete merged branches

# Information
gst                    # Short status
gbr                    # Branches by date
glast                  # Show last commit
ghistory file.js       # File history
```

### Project Management

```bash
# Bookmark projects
padd                   # Add current directory
padd myname            # Add with custom name
p                      # Jump to project (fuzzy)
plist                  # List all projects
prem                   # Remove bookmark

# Quick project creation
newproject my-app      # Creates dir, git init, README, .gitignore
```

### File Operations

```bash
backup file.txt        # Creates timestamped backup
extract archive.zip    # Extract any archive type
cpy file.txt           # Copy file contents to clipboard
pwdc                   # Copy current path to clipboard
```

### Utilities

```bash
serve                  # Start web server (port 8000)
serve 3000             # Custom port
duh                    # Disk usage, sorted
myip                   # Show public IP
localip                # Show local IP
ports                  # List open ports
```

### Quick Edits

```bash
zshrc                  # Edit .zshrc
zshprod                # Edit productivity config
tmuxconf               # Edit tmux config
gitconf                # Edit git config
```

### System

```bash
please                 # Re-run last command with sudo
reload                 # Reload shell
cls                    # Clear screen completely
path                   # Show PATH in readable format
update                 # System update (apt)
```

---

## 💡 Pro Tips

### Combine Commands

```bash
# Find and edit in one go
fe config              # Fuzzy find + preview + edit

# Jump to project and list files
p                      # Select project, auto-lists files

# Search and view with context
search "TODO" | less   # Already piped for you!
```

### Use FZF Shortcuts

All these use fuzzy finding:
- `p` - Project switcher
- `fe` - File editor
- `killp` - Process killer
- `Ctrl-r` - Command history
- `Ctrl-t` - File finder

### Project Workflow Example

```bash
# Monday morning
p                      # Jump to 'work-project'
gpr                    # Pull latest changes
# ... do work ...
gac "implemented feature X"
gacp "fixed bug Y"
gclean                 # Cleanup old branches

# Switch contexts
p                      # Jump to 'side-project'
# Instantly in new context!
```

---

## 🎯 Solving Your Pain Points

### "I type the same commands over and over"

**Before:**
```bash
cd ~/dev/my-long-project-name
git status
git add -A
git commit -m "update"
git push
cd ~/dev/other-project
# repeat...
```

**After:**
```bash
p             # fuzzy select 'my-long'
gacp "update" # done!
p             # switch to 'other'
```

### "Finding things takes forever"

**Before:**
```bash
find . -name "*config*"  # wait...
grep -r "TODO" .         # wait...
history | grep docker    # scroll...
```

**After:**
```bash
ff config    # instant, formatted
search TODO  # with context, colored
hist docker  # filtered instantly
```

### "Context switching is painful"

**Before:**
- Remember 5 different project paths
- `cd` to each one manually
- Forget where things are
- Waste mental energy

**After:**
```bash
p  # Type 2 letters, Enter
   # You're there, files listed
```

---

## 🆘 Help

```bash
ph                     # Show productivity help
productivity-help      # Same thing
```

---

## 🔧 Customization

Edit `~/.zsh_productivity` to:
- Add your own aliases
- Modify existing commands
- Add project-specific shortcuts

Changes are instant (file is sourced on shell start).

---

## 📊 Before & After

### Time Saved Per Day

| Task | Before (seconds) | After (seconds) | Daily Savings |
|------|------------------|-----------------|---------------|
| Switch projects | 30 | 3 | 10× faster |
| Find & edit file | 45 | 5 | 9× faster |
| Git add/commit/push | 25 | 8 | 3× faster |
| Search codebase | 60 | 10 | 6× faster |

**Total daily savings**: ~10-15 minutes of pure execution time + reduced context switching mental load.

Over a year: ~60 hours saved!
