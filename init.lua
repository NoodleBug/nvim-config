--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git', 'clone', '--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
		lazypath
	}
end
vim.opt.rtp:prepend(lazypath)

local status, work = pcall(require, 'work')
local work_plugins = {}
if status then work_plugins = work.get_plugins() end

local corePlugins = {
	-- NOTE: First, some plugins that don't require any configuration

	-- MINE
	-- 'github/copilot.vim', -- Copilot
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		lazy = false, -- specify lazy = false because some lazy.nvim distributions set lazy = true by default
		-- tag = "*",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.concealer"] = {}, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								notes = "~/notes",
							},
						},
					},
				},
			}
		end,
	},
	{
		"ellisonleao/carbon-now.nvim",
		lazy = true,
		cmd = "CarbonNow",
		config = function()
			require("carbon-now").setup({ 
				options = {
					title = "",
					titlebar = "",
					theme = "seti",
					bg = "none",
					line_numbers = false,
					font_size = "12px",
					drop_shadow = true,
					drop_shadow_blur = "20px",
					drop_shadow_offset_y = "0px",
				}
			})
		end,
	},
	'rhysd/vim-fixjson',   -- Json Formatter
	'preservim/nerdtree',  -- File explorer
	-- 'jiangmiao/auto-pairs', -- Auto match brackets
	'mg979/vim-visual-multi', -- Multiple cursors
	{
		"kndndrj/nvim-dbee",
		requires = {
			"MunifTanjim/nui.nvim",
		},
		-- run = function()
		-- 	-- Install tries to automatically detect the install method.
		-- 	-- if it fails, try calling it with one of these parameters:
		-- 	--    "curl", "wget", "bitsadmin", "go"
		-- 	require("dbee").install()
		-- end,
		config = function()
			-- require("dbee").install()
			require("dbee").setup(--[[optional config]])
		end
	},
	{
		'2kabhishek/nerdy.nvim',
		dependencies = {
			'stevearc/dressing.nvim',
			'nvim-telescope/telescope.nvim',
		},
		cmd = 'Nerdy',
	},
	{
		'axkirillov/telescope-changed-files', -- Telescope git working files
		config = function()
			require('telescope').load_extension('changed_files')
		end
	}, 
	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set({ "n", "v" }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
		end,
	},
	"sindrets/diffview.nvim", -- Diffview
	{
		"nathom/tmux.nvim",
		-- config = [[require("config.tmux")]]
		config = function()
			local map = vim.api.nvim_set_keymap
			map("n", "<A-h>", [[<cmd>lua require('tmux').move_left()<cr>]], {})
			map("n", "<A-j>", [[<cmd>lua require('tmux').move_down()<cr>]], {})
			map("n", "<A-k>", [[<cmd>lua require('tmux').move_up()<cr>]], {})
			map("n", "<A-l>", [[<cmd>lua require('tmux').move_right()<cr>]], {})
		end
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- require("dapui").toggle_breakpoint() on <leader>cb
			vim.cmd.nmap('<leader>cb', '<cmd>lua require"dap".toggle_breakpoint()<CR>')

			-- require("dapui").step_into() on F10
			vim.cmd.nmap('<F10>', '<cmd>lua require"dap".step_into()<CR>')

			-- require("dapui").step_over() on F11
			vim.cmd.nmap('<F11>', '<cmd>lua require"dap".step_over()<CR>')

			-- require("dapui").continue() on F5
			vim.cmd.nmap('<F5>', '<cmd>lua require"dap".continue()<CR>')

			-- require("dapui").repl.toggle() on <leader>ci
			vim.cmd.nmap('<leader>ci', '<cmd>lua require"dap".repl.toggle()<CR>')

			local dap = require('dap')
			dap.configurations.javascript = {
				{
					name = 'Launch NodeJS',
					type = 'node',
					request = 'launch',
					program = '${file}',
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = 'inspector',
					console = 'integratedTerminal'
				}
			}
		end
	},
	-- {
	-- 	"rcarriga/nvim-dap-ui",
	-- 	dependencies = { "mfussenegger/nvim-dap" },
	--
	-- 	config = function()
	-- 		-- require("dapui").toggle_breakpoint() on <leader>cb
	-- 		vim.cmd.nmap('<leader>cb', '<cmd>lua require"dap".toggle_breakpoint()<CR>')
	--
	-- 		-- require("dapui").step_into() on F10
	-- 		vim.cmd.nmap('<F10>', '<cmd>lua require"dap".step_into()<CR>')
	--
	-- 		-- require("dapui").step_over() on F11
	-- 		vim.cmd.nmap('<F11>', '<cmd>lua require"dap".step_over()<CR>')
	--
	-- 		-- require("dapui").continue() on F5
	-- 		vim.cmd.nmap('<F5>', '<cmd>lua require"dap".continue()<CR>')
	--
	-- 		-- require("dapui").repl.toggle() on <leader>ci
	-- 		vim.cmd.nmap('<leader>ci', '<cmd>lua require"dap".repl.toggle()<CR>')
	--
	-- 		local dap, dapui = require('dap'), require('dapui')
	--
	-- 		-- javascript configuration
	-- 		dap.configurations.javascript = {
	-- 			{
	-- 				name = 'Launch NodeJS',
	-- 				type = 'node',
	-- 				request = 'launch',
	-- 				program = '${file}',
	-- 				cwd = vim.fn.getcwd(),
	-- 				sourceMaps = true,
	-- 				protocol = 'inspector',
	-- 				console = 'integratedTerminal'
	-- 			}
	-- 		}
	-- 		
	-- 		-- c# configuration (attach to process)
	-- 		dap.adapters.coreclr = {
	-- 			type = "executable",
	-- 			command = vim.fn.stdpath('data') .. "/mason/bin/netcoredbg.cmd",
	-- 			args = { "--interpreter=vscode", "--server" },
	-- 		}
	-- 		dap.configurations.cs = {
	-- 			{
	-- 				name = "Launch",
	-- 				type = "coreclr",
	-- 				request = "launch",
	-- 				program = function()
	-- 					return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
	-- 				end,
	-- 			},
	-- 			-- {
	-- 			-- 	name = "Attach to process",
	-- 			-- 	type = "coreclr",
	-- 			-- 	request = "attach",
	-- 			-- 	-- processId = "${command:pickProcess}"
	-- 			-- 	-- processId = require('dap.utils').pick_process
	-- 			-- 	processId = pick_process
	-- 			-- }
	-- 		}
	-- 		dapui.setup()
	-- 	end
	-- },
	-- {
	--     "Himujjal/tree-sitter-svelte",
	--     branch = "noodlechange", -- specify the branch here
	--     config = function()
	--         require"nvim-treesitter.parsers".get_parser_configs().svelte = {
	--             install_info = {
	--                 url = "https://github.com/Noodle-Bug/tree-sitter-svelte.git",
	--                 files = {"src/parser.c", "src/scanner.c"}, -- include both parser and scanner
	--                 -- Add a generate command if needed
	--                 generate_requires_npm = true, -- if the repo requires npm to run the generate command
	--                 requires_generate_from_grammar = true, -- if you need to generate from the grammar.js file
	--             }
	--         }
	--     end
	-- },
	{ "evanleck/vim-svelte" },
	-- {
	-- 	"Himujjal/tree-sitter-svelte",
	-- 	config = function()
	-- 		require "nvim-treesitter.parsers".get_parser_configs().svelte = {
	-- 			install_info = {
	-- 				url = "https://github.com/Noodle-Bug/tree-sitter-svelte.git",
	-- 				branch = "noodlechange",
	-- 				files = { "src/parser.c" },
	-- 			},
	-- 		}
	-- 	end,
	-- },
	{
		"metakirby5/codi.vim",
		config = function()
			-- use which to find the path to the python interpreter
			local which = vim.fn.system('which python')

			-- if which is empty, try windows where.exe
			if which == '' then
				which = vim.fn.system('where.exe python')
			end

			vim.g.codi = {
				interpreters = {
					python = {
						-- bin = 'C:\\Users\\NoodleBug\\AppData\\Local\\Microsoft\\WindowsApps\\python.exe'
						bin = which,
						-- prompt: '^\(>>>\|\.\.\.\) ',
					}
				}
			}

			-- let g:codi#interpreters = {
			--       \ 'python': {
			--           \ 'bin': 'python',
			--           \ 'prompt': '^\(>>>\|\.\.\.\) ',
			--           \ },
			--       \ }
		end
	}, 'michaeljsmith/vim-indent-object', -- Indent object
	{
		'ThePrimeagen/harpoon',
		-- branch = 'harpoon2',
		config = function()
			require('harpoon').setup({
				menu = { width = vim.api.nvim_win_get_width(0) - 16 }
			})
			require("telescope").load_extension('harpoon')
		end
	},
	{
		'jbyuki/instant.nvim',
		config = function() vim.g.instant_username = 'noodlebug' end
	},
	{
		'ggandor/leap.nvim', -- Jump to any line in a file with labels
		config = function() require('leap').add_default_mappings() end
	},
	{
		'simrat39/symbols-outline.nvim', -- Outline symbols
		config = function() require('symbols-outline').setup({}) end
	},
	{
		"amitds1997/remote-nvim.nvim",
		version = "*", -- This keeps it pinned to semantic releases
		dependencies = {
			"nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			-- This would be an optional dependency eventually
			"nvim-telescope/telescope.nvim"
		},
		config = true -- This calls the default setup(); make sure to call it
	},
	{
		'chipsenkbeil/distant.nvim', -- Remote editing
		branch = 'v0.3',
		config = function() require('distant'):setup() end
	},
	{
		'akinsho/toggleterm.nvim', -- Terminal in a floating window
		version = "*",
		opts = {
			-- direction = 'float',
			-- open_mapping = '<C-\\>',
			-- shell = 'powershell.exe'
		},
		config = function()
			require('toggleterm').setup {
				open_mapping = [[<C-\>]],
				-- shell = 'powershell.exe',
				direction = 'vertical',
				size = 100
			}
			vim.cmd.nnoremap('<M-\\>', ':ToggleTerm direction=float<CR>')
			vim.cmd.nnoremap('|', ':ToggleTerm direction=horizontal<CR>')
		end
	},
	{
		'kdheepak/lazygit.nvim',                     -- Lazygit in a floating window
		config = function()
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_border_chars = {
				'╭', '─', '╮', '│', '╯', '─', '╰', '│'
			}                                   -- customize lazygit popup window border characters
			vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
			vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

			vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
			vim.g.lazygit_config_file_path = '' -- custom config file path
			-- OR
			-- vim.g.lazygit_config_file_path = {} -- table of custom config file paths
		end,
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		"github/copilot.vim", -- Copilot but better
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			-- require("copilot").setup({
			-- 	suggestion = {
			-- 		enable = true,
			-- 		auto_trigger = true,
			-- 	},
			-- })
			-- When pressing Ctrl + C, dismiss suggestion
			vim.cmd.inoremap("<C-c>", "<esc>")
		end
	},
	{
		"kylechui/nvim-surround", -- Modify surrounders ({""})
		version = "*",     -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end
	},
	{
		'stevearc/oil.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {},
		config = function()
			local oil = require('oil')
			oil.setup({
				view_options = { show_hidden = true },
				float = { padding = 10 }
			})
			require('nvim-web-devicons').setup({})
			vim.keymap.set("n", "\\", oil.open_float,
				{ desc = "Open parent directory in oil" })
		end
	},
	{
		'Wansmer/treesj',
		keys = { { '<space>m', '<CMD>TSJToggle<CR>', 'Toggle Treesitter Join' } },
		cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
		opts = { use_default_keymaps = false },
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		config = function()
			require('treesj').setup({ --[[ your config ]] })
		end
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function() vim.cmd("colorscheme catppuccin") end
	},
	-- {
	-- 	'EdenEast/nightfox.nvim',
	-- 	config = function() vim.cmd("colorscheme nightfox") end
	-- }, -- Theme
	{
		'goolord/alpha-nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			-- require 'alpha'.setup(require 'alpha.themes.startify'.config)

			local alpha = require('alpha')
			local dashboard = require('alpha.themes.dashboard')

			dashboard.section.header.val = {
				[[ ____    ___    ___   ___    _        ___ __ __  ____  ___ ___ ]],
				[[|    \  /   \  /   \ |   \  | |      /  _]  |  ||    ||   |   | ]],
				[[|  _  ||     ||     ||    \ | |     /  [_|  |  | |  | | _   _ | ]],
				[[|  |  ||  O  ||  O  ||  D  || |___ |    _]  |  | |  | |  \_/  | ]],
				[[|  |  ||     ||     ||     ||     ||   [_|  :  | |  | |   |   | ]],
				[[|  |  ||     ||     ||     ||     ||     |\   /  |  | |   |   | ]],
				[[|__|__| \___/  \___/ |_____||_____||_____| \_/  |____||___|___| ]]
			}

			if status then
				dashboard.section.header.val = {
					[[ ____    ___    ___   ___    _        ___ __ __  ____  ___ ___ ]],
					[[|    \  /   \  /   \ |   \  | |      /  _]  |  ||    ||   |   | ]],
					[[|  _  ||     ||     ||    \ | |     /  [_|  |  | |  | | _   _ | ]],
					[[|  |  ||  O  ||  O  ||  D  || |___ |    _]  |  | |  | |  \_/  | ]],
					[[|  |  ||     ||     ||     ||     ||   [_|  :  | |  | |   |   | ]],
					[[|  |  ||     ||     ||     ||     ||     |\   /  |  | |   |   | ]],
					[[|__|__| \___/  \___/ |_____||_____||_____| \_/  |____||___|___| ]],
					[[                       Work config loaded                       ]]
				}
			end

			dashboard.section.buttons.val = {
				dashboard.button('c', '  - Open config',
					":execute 'e ' . stdpath('config')<CR>"),
				dashboard.button('r', '  - Recent files',
					':Telescope oldfiles<CR>'),
				dashboard.button('f', '  - Browse files', ":e .<CR>")
			}

			alpha.setup(dashboard.config)
		end
	}, -- Splash screen customization
	-- Git related plugins
	'tpope/vim-fugitive', 'tpope/vim-rhubarb',

	-- Detect tabstop and shiftwidth automatically
	-- 'tpope/vim-sleuth',
	-- {
	--  "askfiy/visual_studio_code",
	--  priority = 100,
	--  config = function()
	--      vim.cmd([[colorscheme visual_studio_code]])
	--  end,
	-- },
	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		'akinsho/flutter-tools.nvim',
		lazy = false,
		dependencies = {
			'nvim-lua/plenary.nvim', 'stevearc/dressing.nvim' -- optional for vim.ui.select
		},
		config = true
	},
	{
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ 'williamboman/mason.nvim', config = true },
			'williamboman/mason-lspconfig.nvim',

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			'folke/neodev.nvim'
		}
	},
	{
		-- Autocompletion
		'hrsh7th/nvim-cmp',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',

			-- Adds LSP completion capabilities
			'hrsh7th/cmp-nvim-lsp', -- Adds a number of user-friendly snippets
			'rafamadriz/friendly-snippets', -- Adds function signature help
			'hrsh7th/cmp-nvim-lsp-signature-help'
		}
	}, -- Useful plugin to show you pending keybinds.
	{ 'folke/which-key.nvim', opts = {} },
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		'lewis6991/gitsigns.nvim',
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = '+' },
				change = { text = '~' },
				delete = { text = '_' },
				topdelete = { text = '‾' },
				changedelete = { text = '~' }
			},
			on_attach = function(bufnr)
				vim.keymap.set('n', '<leader>hp',
					require('gitsigns').preview_hunk,
					{ buffer = bufnr, desc = 'Preview git hunk' })

				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ 'n', 'v' }, ']c', function()
				if vim.wo.diff then return ']c' end
					vim.schedule(function() gs.next_hunk() end)
					return '<Ignore>'
					end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ 'n', 'v' }, '[c', function()
				if vim.wo.diff then return '[c' end
					vim.schedule(function() gs.prev_hunk() end)
					return '<Ignore>'
					end, {
						expr = true,
						buffer = bufnr,
						desc = "Jump to previous hunk"
				})
			end
		}
	}, -- {
	--  -- Theme inspired by Atom
	--  'navarasu/onedark.nvim',
	--  priority = 1000,
	--  config = function()
	--    vim.cmd.colorscheme 'onedark'
	--  end,
	-- },
	{
		-- Set lualine as statusline
		'nvim-lualine/lualine.nvim',
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = false,
				theme = 'onedark',
				component_separators = '|',
				section_separators = ''
			}
		}
	},
	{
		-- Add indentation guides even on blank lines
		'lukas-reineke/indent-blankline.nvim',
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help indent_blankline.txt`
		main = "ibl",
		opts = {}
	}, -- "gc" to comment visual regions/lines
	{
		'numToStr/Comment.nvim',
		opts = {},
		dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
		config = function()
			require('Comment').setup {
				pre_hook = require(
					'ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
			}
			require('ts_context_commentstring').setup {
				context_commentstring = { enable = true, enable_autocmd = false }
			}
		end
	}, -- Fuzzy Finder (files, lsp, etc)
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end
			}
		}
	},
	{
		-- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
		build = ':TSUpdate',
		commit = '33eb472b459f1d2bf49e16154726743ab3ca1c6d',
		config = function() end
		-- Locking this to this commit to keep Flutter / Dart from lagging until this issue is fixed:
		-- https://github.com/nvim-treesitter/nvim-treesitter/issues/4945
	}

	-- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
	--       These are some example plugins that I've included in the kickstart repository.
	--       Uncomment any of the lines below to enable them.
	-- require 'kickstart.plugins.autoformat',
	-- require 'kickstart.plugins.debug',

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
	--    up-to-date with whatever is in the kickstart repo.
	--    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	--
	--    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
	-- { import = 'custom.plugins' },
}

-- Loop through work plugins and append to core plugins
for _, plugin in pairs(work_plugins) do table.insert(corePlugins, plugin) end

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup(corePlugins)

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight',
	{ clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function() vim.highlight.on_yank() end,
	group = highlight_group,
	pattern = '*'
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
	defaults = {
		path_display = { "truncate" },
		file_ignore_patterns = { "node_modules" },
		mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } }
	},
	pickers = {
		live_grep = {
			vimgrep_arguments = {
				"rg", "--color=never", "--no-heading", "--with-filename",
				"--line-number", "--column", "--smart-case", "-l"
			}
		}
	}
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles,
	{ desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers,
	{ desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require('telescope.builtin').current_buffer_fuzzy_find(require(
		'telescope.themes').get_dropdown {
		winblend = 10,
		previewer = false
	})
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files,
	{ desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files,
	{ desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags,
	{ desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string,
	{ desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep,
	{ desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics,
	{ desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume,
	{ desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require('nvim-treesitter.configs').setup {
		-- Add languages to be installed here that you want installed for treesitter

		-- --  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim' },
		-- ensure_installed = {
		-- 	'glimmer', 'javascript', 'lua', 'python', 'rust', 'tsx',
		-- 	'typescript', 'vim', 'vimdoc'
		-- },

		-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
		-- auto_install = false,
		auto_install = true,

		-- Comment support for jsx / tsx
		-- context_commentstring = {
		-- 	enable = true,
		-- },

		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = '<c-space>',
				node_incremental = '<c-space>',
				scope_incremental = '<c-s>',
				node_decremental = '<M-space>'
			}
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					['aa'] = '@parameter.outer',
					['ia'] = '@parameter.inner',
					['af'] = '@function.outer',
					['if'] = '@function.inner',
					['ac'] = '@class.outer',
					['ic'] = '@class.inner'
				}
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					[']m'] = '@function.outer',
					[']]'] = '@class.outer'
				},
				goto_next_end = {
					[']M'] = '@function.outer',
					[']['] = '@class.outer'
				},
				goto_previous_start = {
					['[m'] = '@function.outer',
					['[['] = '@class.outer'
				},
				goto_previous_end = {
					['[M'] = '@function.outer',
					['[]'] = '@class.outer'
				}
			},
			swap = {
				enable = true,
				swap_next = { ['<leader>a'] = '@parameter.inner' },
				swap_previous = { ['<leader>A'] = '@parameter.inner' }
			}
		}
	}
end, 0)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
	{ desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
	{ desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
	{ desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
	{ desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then desc = 'LSP: ' .. desc end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
	nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
	nmap('gr', function()
		require('telescope.builtin').lsp_references {
			path_display = 'smart',
			show_line = false
		}
	end, '[G]oto [R]eferences')
	nmap('gI', require('telescope.builtin').lsp_implementations,
		'[G]oto [I]mplementation')
	nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
	nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols,
		'[D]ocument [S]ymbols')
	nmap('<leader>ws',
		require('telescope.builtin').lsp_dynamic_workspace_symbols,
		'[W]orkspace [S]ymbols')

	-- See `:help K` for why this keymap
	nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
	nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Lesser used LSP functionality
	nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	nmap('<leader>wa', vim.lsp.buf.add_workspace_folder,
		'[W]orkspace [A]dd Folder')
	nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder,
		'[W]orkspace [R]emove Folder')
	nmap('<leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, '[W]orkspace [L]ist Folders')

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, 'Format',
		function(_) vim.lsp.buf.format() end, {
			desc = 'Format current buffer with LSP'
		})
end

-- document existing key chains
require('which-key').register({
	['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
	['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
	['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
	['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
	['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
	['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
	['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' }
})

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	-- html = { filetypes = { 'html', 'twig', 'hbs'} },

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false }
		}
	}
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup { ensure_installed = vim.tbl_keys(servers) }

mason_lspconfig.setup_handlers {
	function(server_name)
		require('lspconfig')[server_name].setup {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes
		}
	end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
	snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-e>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true
		},
		['<c-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' })
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' }, { name = 'copilot' },
		{ name = 'nvim_lsp_signature_help' }
	}
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--

local flutterTools = require('flutter-tools')
flutterTools.setup { flutter_path = 'C:/flutter/bin/flutter.bat' }

-- Set relativenumber
vim.wo.relativenumber = true

-- Disable swap file
vim.cmd.autocmd('VimEnter', '*', 'set noswapfile')
vim.cmd.autocmd('VimEnter', '*', 'set autoread')

-- Tab config
vim.opt.tabstop = 8
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Custom commands / mappings
vim.cmd.autocmd('BufNewFile,BufRead', '*', 'setlocal formatoptions=cr')   -- Don't auto insert as a comment when pressing O
vim.cmd.autocmd('TermOpen', '*', 'setlocal nonumber norelativenumber')    -- No line numbers in terminal
vim.cmd.command('EditConfig', ":execute 'e ' . stdpath('config')<CR>")    -- Edit config file
vim.cmd.nnoremap('<leader>F', ':NERDTreeToggle<CR>')                      -- Open nerdtree file explorer
vim.cmd.nnoremap('<leader>L', ':LazyGit<CR>')                             -- Open lazygit (git gui)
vim.cmd.nmap('<M-J>', '`o<Esc>``')                                        -- Insert new line below current line
vim.cmd.nmap('<M-K>', '`O<Esc>``')                                        -- Insert new line above current line
vim.cmd.tnoremap('<C-h>', '<C-\\><C-n>')                                  -- Exit terminal mode with control + h
vim.cmd.nmap('m<leader>', ':lua require("harpoon.mark").add_file()<CR>')  -- Map m + space to add mark to harpoon
vim.cmd.nmap('g``', ':lua require("harpoon.ui").toggle_quick_menu()<CR>') -- Map g + `` to toggle harpoon menu')
vim.cmd.nmap('g`1', ':lua require("harpoon.ui").nav_file(1)<CR>')         -- Map g + `1 to go to harpoon mark 1
vim.cmd.nmap('g`2', ':lua require("harpoon.ui").nav_file(2)<CR>')         -- Map g + `2 to go to harpoon mark 2
vim.cmd.nmap('g`3', ':lua require("harpoon.ui").nav_file(3)<CR>')         -- Map g + `3 to go to harpoon mark 3
vim.cmd.nmap('g`4', ':lua require("harpoon.ui").nav_file(4)<CR>')         -- Map g + `4 to go to harpoon mark 4
vim.cmd.nmap('g`5', ':lua require("harpoon.ui").nav_file(5)<CR>')         -- Map g + `5 to go to harpoon mark 5
vim.cmd.nmap('g`6', ':lua require("harpoon.ui").nav_file(6)<CR>')         -- Map g + `6 to go to harpoon mark 6
vim.cmd.nmap('g`7', ':lua require("harpoon.ui").nav_file(7)<CR>')         -- Map g + `7 to go to harpoon mark 7
vim.cmd.nmap('g`8', ':lua require("harpoon.ui").nav_file(8)<CR>')         -- Map g + `8 to go to harpoon mark 8
vim.cmd.nmap('g`9', ':lua require("harpoon.ui").nav_file(9)<CR>')         -- Map g + `9 to go to harpoon mark 9
vim.cmd.nmap('g`0', ':lua require("harpoon.ui").nav_file(10)<CR>')        -- Map g + `0 to go to harpoon mark 10
-- Customize nightfox theme
-- require('nightfox').setup({
-- 	-- Comment support for jsx / tsx
-- 	-- palettes = {
-- 	-- 	nightfox = {
-- 	-- 		comment = "#F9F1A5", -- bright yellow
-- 	-- 	},
-- 	-- },
-- })

-- Fix powershell encoding (for LazyGit)
local powershell_options = {
	-- shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
	shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell.exe",
	shellcmdflag =
	"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
	shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
	shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
	shellquote = "",
	shellxquote = ""
}
-- Only set the options if the shell is powershell
if vim.fn.executable "pwsh" == 1 or vim.fn.executable "powershell.exe" == 1 then
	for option, value in pairs(powershell_options) do vim.opt[option] = value end
end

-- vim.g.python3_host_prog = 'C:\\Users\\adysart\\AppData\\Local\\Programs\\Python\\Python312\\python.exe'
-- vim.g.python_host_prog = 'C:\\Users\\adysart\\AppData\\Local\\Programs\\Python\\Python312\\python.exe'

-- vim.cmd("highlight Comment guifg=#F9F1A5");

-- vim.g.tmux_navigator_no_mappings = 1
-- vim.cmd.noremap('<silent> {Left-Mapping}', ':TmuxNavigateLeft<cr>')
-- vim.cmd.noremap('<silent> {Down-Mapping}', ':TmuxNavigateDown<cr>')
-- vim.cmd.noremap('<silent> {Up-Mapping}', ':TmuxNavigateUp<cr>')
-- vim.cmd.noremap('<silent> {Right-Mapping}', ':TmuxNavigateRight<cr>')
-- vim.cmd.noremap('<silent> {Previous-Mapping}', ':TmuxNavigatePrevious<cr>')

-- vim.api.nvim_set_keymap('n', '<A-l>', ':TmuxNavigateRight<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<A-j>', ':TmuxNavigateDown<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<A-h>', ':TmuxNavigateLeft<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<A-k>', ':TmuxNavigateUp<CR>', { noremap = true, silent = true })

-- Force transparent background
-- vim.cmd('highlight Normal guibg=none')
-- vim.cmd('highlight Normal ctermbg=none')
-- vim.cmd('highlight NonText guibg=none')
-- vim.cmd('highlight NonText ctermbg=none')

-- -- Force transparent background
-- vim.cmd([[
--   highlight Normal guibg=none
--   highlight NormalNC guibg=none
--   highlight NonText guibg=none
--   highlight VertSplit guibg=none
--   highlight StatusLine guibg=none
--   highlight StatusLineNC guibg=none
--   highlight NormalFloat guibg=none
-- ]])

-- Force transparent background only if we're in linux
if vim.fn.has('unix') == 1 then
	vim.cmd([[
	   highlight Normal guibg=none
	   highlight NormalNC guibg=none
	   highlight NonText guibg=none
	   highlight VertSplit guibg=none
	   highlight StatusLine guibg=none
	   highlight StatusLineNC guibg=none
	   highlight NormalFloat guibg=none
   ]])
end
