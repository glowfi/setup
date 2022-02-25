-- Settings
local status_ok, comments = pcall(require, "nvim_comment")
if not status_ok then
	return
end

comments.setup({
	comment_empty = false,
	hook = function()
		require("ts_context_commentstring.internal").update_commentstring()
	end,
})

-- Keymappings
vim.api.nvim_set_keymap("n", "<C-_>", ":CommentToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-_>", ":CommentToggle<CR>", { noremap = true, silent = true })
