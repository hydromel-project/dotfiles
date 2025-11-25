-- ============================================================================
-- Core Options - Sensible defaults for modern development
-- ============================================================================

local opt = vim.opt

-- Leader key (must be set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Performance
opt.updatetime = 250 -- Faster completion and CursorHold events
opt.timeoutlen = 300 -- Faster key sequence completion

-- UI & Appearance
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers for easier navigation
opt.signcolumn = "yes" -- Always show sign column to prevent layout shifts
opt.cursorline = true -- Highlight current line
opt.colorcolumn = "80,120" -- Show rulers at 80 and 120 characters
opt.wrap = false -- Don't wrap lines
opt.linebreak = true -- Break lines at word boundaries when wrap is on
opt.showmode = false -- Don't show mode in command line (statusline handles it)
opt.conceallevel = 2 -- Conceal markup in markdown
opt.shortmess:append("c") -- Don't give completion messages

-- Search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true -- Case sensitive when uppercase present
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Indentation size
opt.tabstop = 2 -- Tab size
opt.softtabstop = 2 -- Tab size in insert mode
opt.shiftround = true -- Round indent to multiple of shiftwidth
opt.smartindent = true -- Auto indent new lines

-- Completion
opt.completeopt = "menu,menuone,noselect" -- Better completion experience
opt.pumheight = 10 -- Limit popup menu height

-- Files
opt.autowrite = true -- Auto save before commands like :next
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.backup = false -- Don't create backup files
opt.writebackup = false -- Don't create backup before overwriting
opt.swapfile = false -- Don't create swap files
opt.undofile = true -- Enable persistent undo
opt.undolevels = 10000 -- Maximum number of undo levels

-- Behavior
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.splitbelow = true -- New horizontal splits below current
opt.splitright = true -- New vertical splits to the right
opt.inccommand = "split" -- Live preview of substitutions
opt.scrolloff = 4 -- Keep 4 lines visible around cursor
opt.sidescrolloff = 8 -- Keep 8 columns visible around cursor
opt.wildmode = "longest:full,full" -- Better command completion

-- Folding (using Treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- Open all folds by default
opt.foldtext = "" -- Use Treesitter for fold text

-- Terminal
opt.shell = vim.fn.executable("zsh") == 1 and "zsh" or "bash"

-- Performance optimizations
opt.lazyredraw = false -- Don't redraw during macros (disabled as it can cause issues)
opt.ttyfast = true -- Optimize for fast terminal connections
opt.regexpengine = 1 -- Use old regexp engine (sometimes faster)

-- Fix common issues
opt.backspace = "indent,eol,start" -- Intuitive backspacing
opt.formatoptions:remove({ "c", "r", "o" }) -- Don't continue comments on new lines

-- Security
opt.modeline = false -- Disable modeline for security