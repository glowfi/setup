-- Settings

-- Automatically install lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local status_ok, _ = pcall(require, "lazy")
if not status_ok then
	return
end

-- Plugins
return require("lazy").setup({
	-- Utilities

	-- NNN File Manager
	{
		"mcchrish/nnn.vim",
		config = function()
			require("core.filemanager")
		end,
	},

	-- Fuzzy search
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzy-native.nvim" },
		},
		config = function()
			require("core.telescope")
		end,
	},

	-- Git Integration
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("core.gitsigns")
		end,
		event = "BufRead",
	},

	-- Code Runner
	{
		"sbdchd/vim-run",
		config = function()
			require("core.coderunner")
		end,
		ft = { "javascript", "typescript", "python" },
	},

	-- Multi Cursor
	{
		"mg979/vim-visual-multi",
		config = function()
			require("core.visualMulti")
		end,
	},

	-- Auto Comments
	{
		"terrortylor/nvim-comment",
		config = function()
			require("core.comments")
		end,
		event = "BufRead",
	},

	-- Tabs
	{
		"romgrk/barbar.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		event = "BufRead",
		config = function()
			require("core.bufferline")
		end,
	},

	-- Visual

	-- Gruvbox theme
	{
		"ellisonleao/gruvbox.nvim",
		dependencies = { "rktjmp/lush.nvim" },
		config = function()
			require("core.colorscheme")
		end,
	},

	-- Status line
	{
		"hoob3rt/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("core.statusline")
		end,
		event = "BufWinEnter",
	},

	-- Dashboard
	{
		"glepnir/dashboard-nvim",
		event = "BufWinEnter",
		config = function()
			require("core.dashboard")
		end,
	},

	-- Zenmode
	{
		"folke/zen-mode.nvim",
		config = function()
			require("core.zenmode")
		end,
	},

	-- Indentline
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		config = function()
			require("core.indentline")
		end,
	},

	-- Treesitter integrations

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("core.treesitter")
		end,
	},

	-- Treesitter text-objects
	{ "nvim-treesitter/nvim-treesitter-textobjects" },

	-- Treesitter playground
	{ "nvim-treesitter/playground" },

	-- Bracket Matchup
	{ "andymass/vim-matchup" },

	-- Smart Commenting for complex filetypes
	{ "JoosepAlviste/nvim-ts-context-commentstring" },

	-- HTML Autotag and Autorename tags
	{
		"windwp/nvim-ts-autotag",
		ft = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"javascript.jsx",
			"typescript.tsx",
		},
	},

	-- LSP

	--   nvim native LSP
	{ "neovim/nvim-lspconfig" },

	--   Auto completion
	{
		"hrsh7th/nvim-cmp",
		after = "nvim-lspconfig",
		event = "InsertEnter *",
		config = function()
			require("lsp.cmp")
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		config = function()
			require("cmp_nvim_lsp").setup({})
		end,
	},
	{ "hrsh7th/cmp-path", after = "nvim-cmp" },
	{ "hrsh7th/cmp-buffer", after = "nvim-cmp" },

	--   Snippet Engine and Snippets
	{
		"hrsh7th/vim-vsnip",
		after = "nvim-cmp",
		event = "InsertCharPre",
		config = function()
			require("lsp.vsnip")
		end,
	},
	{ "hrsh7th/cmp-vsnip", after = "nvim-cmp" },
	{ "rafamadriz/friendly-snippets", event = "InsertCharPre" },
	{ "wyattferguson/jinja2-kit-vscode", event = "InsertCharPre" },

	--   Signature popup on typing
	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp.sigHelp")
		end,
	},

	--   Auto pairs
	{
		"windwp/nvim-autopairs",
		after = "nvim-cmp",
		config = function()
			require("lsp.autopairs")
		end,
	},

	--   Null-ls
	{ "jose-elias-alvarez/null-ls.nvim" },

	-- Languages Plugins

	--   Typescript
	{
		"jose-elias-alvarez/typescript.nvim",
		ft = {
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"javascript.jsx",
			"typescript.tsx",
		},
	},

	--   Markdown
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && yarn install",
		ft = { "markdown" },
		config = function()
			require("core.mkdp")
		end,
		cmd = "MarkdownPreview",
	},

	{
		"lukas-reineke/headlines.nvim",
		config = function()
			require("core.headlines")
		end,
		ft = { "markdown" },
	},
})
