-- Settings
local status_ok, comments = pcall(require, "nvim_comment")
if not status_ok then
	return
end

-- Setup
comments.setup({
	comment_empty = false,
	hook = function()
		require("ts_context_commentstring.internal").update_commentstring()
	end,
})

-- Speedup loading
vim.g.skip_ts_context_commentstring_module = true

-- Keymappings
vim.api.nvim_set_keymap("n", "<C-/>", ":CommentToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-/>", ":CommentToggle<CR>", { noremap = true, silent = true })
