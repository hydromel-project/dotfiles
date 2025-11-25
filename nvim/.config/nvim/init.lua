-- ============================================================================
-- Neovim 0.12 Configuration - Ready for vim.pack.add when available
-- ============================================================================

-- Core options
vim.g.mapleader = " "
vim.g.maplocalleader = " "



-- Essential options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 4
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Plugin management - ready for vim.pack.add when available
local function setup_plugins()
  local plugins_to_install = {
    'https://github.com/catppuccin/nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/williamboman/mason.nvim',
    'https://github.com/williamboman/mason-lspconfig.nvim',
    'https://github.com/hrsh7th/nvim-cmp',
    'https://github.com/hrsh7th/cmp-nvim-lsp',
    'https://github.com/hrsh7th/cmp-nvim-lsp-signature-help',
    'https://github.com/L3MON4D3/LuaSnip',
    'https://github.com/saadparwaiz1/cmp_luasnip',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-ui-select.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-tree/nvim-tree.lua',
  }
 

  -- Try vim.pack.add if available (safe check)
  local pack_available, pack_result = pcall(function() 
    return vim.pack and vim.pack.add 
  end)
  
  if pack_available and pack_result then
    local success = pcall(function()
      vim.pack.add(plugins_to_install, { 
        load = true,
        confirm = false 
      })
    end)
    if success then
      return true
    end
  end
  
  vim.defer_fn(function()
    vim.notify("📦 vim.pack.add not available in this build", vim.log.levels.INFO, { title = "Plugin Info" })
  end, 200)
  return false
end

-- Essential keymaps
local map = vim.keymap.set

-- Better navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Clear search
map("n", "<esc>", "<cmd>noh<cr>", { desc = "Clear search" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Trim trailing whitespace function
local function trim_whitespace()
  local save_cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[%s/\s\+$//e]])
  vim.api.nvim_win_set_cursor(0, save_cursor)
end

-- Trim whitespace keymap
map("n", "<leader>tw", trim_whitespace, { desc = "Trim whitespace" })

-- Save file
map({"n", "i", "v"}, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- File operations with smart fallbacks
map("n", "<leader>ff", function()
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.find_files()
  else
    -- Use built-in find with better UX
    vim.ui.input({ 
      prompt = "Find files (pattern): ",
      default = "**/*"
    }, function(input)
      if input and input ~= "" then
        vim.cmd("find " .. input)
      end
    end)
  end
end, { desc = "Find Files" })

map("n", "<leader>sg", function()
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.live_grep()
  else
    vim.ui.input({ prompt = "Grep for: " }, function(input)
      if input and input ~= "" then
        vim.cmd("silent grep! " .. vim.fn.shellescape(input) .. " **/*")
        vim.cmd("copen")
      end
    end)
  end
end, { desc = "Search/Grep" })

map("n", "<leader>fb", function()
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.buffers()
  else
    vim.cmd("ls")
    vim.ui.input({ prompt = "Go to buffer: " }, function(input)
      if input and input ~= "" then
        vim.cmd("buffer " .. input)
      end
    end)
  end
end, { desc = "Buffers" })

-- File explorer (nvim-tree)
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File Explorer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Mason LSP management
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason LSP Manager" })

-- LSP info and diagnostics
map("n", "<leader>li", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.WARN)
  else
    for _, client in ipairs(clients) do
      vim.notify("LSP: " .. client.name .. " (id: " .. client.id .. ")", vim.log.levels.INFO)
    end
  end
end, { desc = "LSP Info" })

map("n", "<leader>lr", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.defer_fn(function()
    vim.cmd("edit")
    vim.notify("LSP restarted", vim.log.levels.INFO)
  end, 500)
end, { desc = "LSP Restart" })

-- Terminal/Git
map("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") == 1 then
    vim.cmd("terminal lazygit")
  else
    vim.cmd("terminal git status")
  end
end, { desc = "Git" })

-- LSP keymaps are now handled in LspAttach autocmd for better reliability

-- Diagnostic navigation (works with built-in diagnostics)
if pcall(function() return vim.diagnostic end) then
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
end

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Set a nice built-in colorscheme
pcall(function() 
  vim.cmd.colorscheme("habamax") 
end)

-- Try to setup plugins
local plugins_available = setup_plugins()

-- Plugin configurations (only run if plugins were loaded)
if plugins_available then
  vim.defer_fn(function()
    -- Colorscheme
    pcall(function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
      vim.cmd.colorscheme("catppuccin")
    end)
    
    -- Treesitter
    pcall(function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        ensure_installed = { 
          "lua", "vim", "vimdoc",
          "javascript", "typescript", "tsx", "jsdoc",
          "svelte", 
          "php", "phpdoc",
          "python",
          "html", "css", "scss",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "bash", "regex"
        },
      })
    end)
    
    -- Mason LSP management
    pcall(function()
      require("mason").setup({
        ui = {
          border = "rounded",
          width = 0.8,
          height = 0.8,
        }
      })
    end)
    
    pcall(function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",           -- Lua
          "pyright",          -- Python
          "ts_ls",            -- TypeScript/JavaScript
          -- "svelte",           -- Svelte 5 (disabled - might cause URI issues)
          -- "tailwindcss",      -- Tailwind CSS (disabled)
          "jsonls",           -- JSON
          -- "yamlls",           -- YAML (disabled - known to cause URI issues)
          "html",             -- HTML
          "cssls",            -- CSS
        },
        automatic_installation = false,  -- Disable automatic installation to prevent startup issues
      })
    end)
    
    -- LSP configuration using native vim.lsp.config (Neovim 0.12+)
    pcall(function()
      local capabilities = pcall(require, "cmp_nvim_lsp") and require("cmp_nvim_lsp").default_capabilities() or vim.lsp.protocol.make_client_capabilities()
      
      -- Enable snippet support and enhanced completion
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" }
      }
      capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
      capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
      
      -- Add LSP attach autocommand for debugging and key mappings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            local filename = vim.fn.expand('%:t')
            local filetype = vim.bo.filetype
            vim.notify("LSP attached: " .. client.name .. " to " .. filename .. " (ft:" .. filetype .. ")", vim.log.levels.INFO)
            
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
            
            -- Buffer local mappings for LSP
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<leader>f', function()
              vim.lsp.buf.format { async = true }
            end, opts)
            
            -- Auto-trigger signature help when typing function parameters
            vim.keymap.set('i', '(', function()
              vim.api.nvim_feedkeys('(', 'n', false)
              vim.defer_fn(function()
                vim.lsp.buf.signature_help()
              end, 100)
            end, { buffer = ev.buf, silent = true })
            
            -- For PHP files, trigger completion on $ for variables
            if vim.bo.filetype == "php" then
              vim.keymap.set('i', '$', function()
                vim.api.nvim_feedkeys('$', 'n', false)
                vim.defer_fn(function()
                  require('cmp').complete()
                end, 50)
              end, { buffer = ev.buf, silent = true })
            end
          end
        end,
      })
      
      -- Configure LSP servers using the proper 2025 API: vim.lsp.config() + vim.lsp.enable()
      
      -- Set global defaults for all LSP servers
      vim.lsp.config('*', {
        capabilities = capabilities,
        root_markers = { '.git' }, -- Default fallback
      })
      
      -- Lua language server configuration
      vim.lsp.config('lua_ls', {
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/lua-language-server") },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME }
            }
          }
        }
      })
      
      -- Python language server configuration with enhanced type checking
      vim.lsp.config('pyright', {
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/pyright-langserver"), "--stdio" },
        filetypes = { "python" },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "strict", -- Enhanced type checking for better suggestions
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              autoImportCompletions = true,
              diagnosticMode = "workspace",
              -- Enhanced completion settings
              completeFunctionParens = true,
              includePackageImportsInAutoImports = true,
            }
          }
        }
      })
      
      -- PHP language server configuration (Intelephense) with enhanced type-aware completion
      vim.lsp.config('intelephense', {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        root_markers = { 'composer.json', '.git' },
        init_options = {
          storagePath = vim.fn.expand("~/.local/share/intelephense"),
          clearCache = false,
        },
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000,
              associations = { "*.php", "*.phtml" },
              exclude = { "**/vendor/**", "**/node_modules/**", "**/.git/**" }
            },
            completion = {
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
              triggerParameterHints = true,
              maxItems = 100,
              -- Enhanced type-aware completion settings
              suggestBasicKeywords = true,
              suggestArguments = true,
              suggestVariables = true,
              suggestMethods = true,
            },
            format = {
              enable = true
            },
            -- Enhanced type inference and analysis
            diagnostics = {
              enable = true,
              run = "onType",
              delay = 1000,
            },
            -- Better type analysis for more accurate suggestions
            phpdoc = {
              returnVoid = true,
              textFormat = "snippet"
            }
          }
        }
      })
      
      -- TypeScript/JavaScript language server configuration with type-aware completion
      vim.lsp.config('ts_ls', {
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/typescript-language-server"), "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
        init_options = {
          preferences = {
            -- Enhanced type-aware completion preferences
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithSnippetText = true,
            includeAutomaticOptionalChainCompletions = true,
            providePrefixAndSuffixTextForRename = true,
            allowRenameOfImportPath = true,
            includePackageJsonAutoImports = "auto",
            -- Type-based filtering
            includeCompletionsWithClassMemberSnippets = true,
            includeCompletionsWithObjectLiteralMethodSnippets = true,
          }
        },
        settings = {
          typescript = {
            suggest = {
              includeCompletionsForModuleExports = true,
              includeAutomaticOptionalChainCompletions = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
            }
          },
          javascript = {
            suggest = {
              includeCompletionsForModuleExports = true,
              includeAutomaticOptionalChainCompletions = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
            }
          }
        }
      })
      
      -- Enable all configured LSP servers
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('pyright') 
      vim.lsp.enable('intelephense')
      vim.lsp.enable('ts_ls')
      
    end)
    
    -- Completion with enhanced function signature support
    pcall(function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/snippets" })
      
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ 
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        completion = {
          autocomplete = {
            cmp.TriggerEvent.TextChanged,
          },
          keyword_pattern = [[\k\+]], -- Include $ for PHP variables
          keyword_length = 1,
          completeopt = 'menu,menuone,noinsert',
        },
        sources = cmp.config.sources({
          { 
            name = "nvim_lsp", 
            priority = 1000,
            -- Enhanced LSP source configuration for type-aware completion
            entry_filter = function(entry, ctx)
              local kind = entry:get_kind()
              local line = ctx.cursor_line
              local col = ctx.cursor.col
              
              -- For PHP: prioritize variables that match expected types
              if ctx.filetype == "php" then
                -- If we're in a function parameter context, prioritize matching types
                local before_cursor = string.sub(line, 1, col - 1)
                
                -- Check if we're in a function call context
                if before_cursor:match("%(") and not before_cursor:match("%);%s*$") then
                  -- Prioritize variables and methods over keywords in function calls
                  return kind == require('cmp').lsp.CompletionItemKind.Variable or
                         kind == require('cmp').lsp.CompletionItemKind.Method or
                         kind == require('cmp').lsp.CompletionItemKind.Function
                end
              end
              
              return true
            end
          },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 750 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Show source and enhanced type information
            local source_name = ({
              nvim_lsp = "[LSP]",
              nvim_lsp_signature_help = "[Signature]", 
              luasnip = "[Snippet]",
            })[entry.source.name]
            
            -- For LSP entries, try to show type information
            if entry.source.name == "nvim_lsp" and entry.completion_item then
              local completion_item = entry.completion_item
              
              -- Show type information if available
              if completion_item.detail and completion_item.detail ~= "" then
                local detail = completion_item.detail
                -- For PHP variables, show their inferred type
                if detail:match("^%$") then -- PHP variable
                  local var_type = detail:match(":%s*(.+)") or detail:match("%((.+)%)")
                  if var_type then
                    vim_item.menu = source_name .. " " .. var_type
                  else
                    vim_item.menu = source_name .. " var"
                  end
                else
                  -- Truncate long type information  
                  local short_detail = string.len(detail) > 20 and string.sub(detail, 1, 17) .. "..." or detail
                  vim_item.menu = source_name .. " " .. short_detail
                end
              else
                vim_item.menu = source_name
              end
            else
              vim_item.menu = source_name
            end
            
            return vim_item
          end,
        },
        
        experimental = {
          ghost_text = true,
        },
      })
    end)
    
    -- Git signs
    pcall(function()
      require("gitsigns").setup()
    end)
    
    -- Status line
    pcall(function()
      require("lualine").setup({
        options = { theme = "auto" },
      })
    end)
    
    -- Nvim-tree file explorer
    pcall(function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          add_trailing = false,
          group_empty = false,
          highlight_git = false,
          full_name = false,
          highlight_opened_files = "none",
          root_folder_modifier = ":~",
          indent_width = 2,
          indent_markers = {
            enable = false,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            modified_placement = "after",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "󰆤",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
          special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
          symlink_destination = true,
        },
        update_focused_file = {
          enable = true,
          update_root = false,
          ignore_list = {},
        },
        filters = {
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          custom = { ".DS_Store" },
          exclude = {},
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        git = {
          enable = true,
          ignore = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          timeout = 400,
        },
        modified = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = {},
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = "cursor",
              border = "shadow",
              style = "minimal",
            },
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        trash = {
          cmd = "gio trash",
        },
        live_filter = {
          prefix = "[FILTER]: ",
          always_show_folders = true,
        },
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },
        notify = {
          threshold = vim.log.levels.INFO,
        },
        ui = {
          confirm = {
            remove = true,
            trash = true,
          },
        },
      })
    end)

    -- Which-key with beautiful styling
    pcall(function()
      require("which-key").setup({
        preset = "modern",
        win = {
          border = "rounded",
          padding = { 1, 2 },
          title = true,
          title_pos = "center",
          zindex = 1000,
        },
        layout = {
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "center",
        },
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
        },
        show_help = true,
        show_keys = true,
        disable = {
          buftypes = {},
          filetypes = { "TelescopePrompt" },
        },
      })
    end)
    
    -- Telescope with UI Select extension
    pcall(function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              layout_config = {
                width = 0.8,
                height = 0.6,
              }
            })
          }
        }
      })
      
      -- Load ui-select extension
      require("telescope").load_extension("ui-select")
    end)
    
    vim.cmd("redraw")
    vim.notify("⚡ Neovim 0.12 with plugins ready!", vim.log.levels.INFO, { title = "Config Loaded" })
  end, 150)
else
  -- Show ready message for basic config
  vim.defer_fn(function()
    vim.cmd("redraw")
    vim.notify("⚡ Neovim 0.12 ready! (Excellent built-in functionality)", vim.log.levels.INFO, { title = "Config Loaded" })
  end, 100)
end
