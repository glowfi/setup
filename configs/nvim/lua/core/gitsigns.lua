-- Settings
local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
	return
end

gitsigns.setup({
	signs = {
		add = {
			hl = "GitSignsAdd",
			text = "┃ ",
			numhl = "GitSignsAddNr",
			linehl = "GitSignsAddLn",
		},
		change = {
			hl = "GitSignsChange",
			text = "┃ ",
			numhl = "GitSignsChangeNr",
			linehl = "GitSignsChangeLn",
		},
		delete = {
			hl = "GitSignsDelete",
			text = "契",
			numhl = "GitSignsDeleteNr",
			linehl = "GitSignsDeleteLn",
		},
		topdelete = {
			hl = "GitSignsDelete",
			text = "契",
			numhl = "GitSignsDeleteNr",
			linehl = "GitSignsDeleteLn",
		},
		changedelete = {
			hl = "GitSignsChange",
			text = "┃ ",
			numhl = "GitSignsChangeNr",
			linehl = "GitSignsChangeLn",
		},
	},
	on_attach = function(bufnr)
		vim.keymap.set(
			"n",
			"<leader>hp",
			require("gitsigns").preview_hunk,
			{ buffer = bufnr, desc = "Preview git hunk" }
		)

		-- don't override the built-in and fugitive keymaps
		local gs = package.loaded.gitsigns
		vim.keymap.set({ "n", "v" }, "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
		vim.keymap.set({ "n", "v" }, "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
	end,
	numhl = false,
	linehl = false,
	watch_gitdir = { interval = 1000 },
	sign_priority = 6,
	update_debounce = 200,
	status_formatter = nil,
})
