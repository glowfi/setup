-- Settings
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	-- Treesitter
	ensure_installed = {
		"python",
		"go",
		"rust",
		"zig",
		"javascript",
		"typescript",
		"tsx",
		"html",
		"css",
		"c",
		"cpp",
		"json",
		"lua",
		"bash",
		"fish",
		"sql",
		"yaml",
		"toml",
		"markdown",
		"latex",
		"dockerfile",
		"csv",
		"gomod",
		"requirements",
	},
	highlight = { enable = true, additional_vim_regex_highlighting = true },
	incremental_selection = {
		enable = true,
		disable = { "cpp", "lua" },
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	-- Textobjects
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
	-- Playground
	playground = {
		enable = true,
		disable = {},
		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = false, -- Whether the query persists across vim sessions
		keybindings = {
			toggle_query_editor = "o",
			toggle_hl_groups = "i",
			toggle_injected_languages = "t",
			toggle_anonymous_nodes = "a",
			toggle_language_display = "I",
			focus_language = "f",
			unfocus_language = "F",
			update = "R",
			goto_node = "<cr>",
			show_help = "?",
		},
	},
	-- Matchup
	matchup = { enable = true },
	-- Autotag/Auto Rename HTML Tags
	autotag = {
		enable = true,
		filetypes = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
		},
	},
	-- Smart Commenting
	require("ts_context_commentstring").setup({
		enable_autocmd = false,
	}),
})

-- Matchup
vim.cmd("let g:matchup_surround_enabled = 1")
vim.g.matchup_matchparen_offscreen = { method = "popup" }
