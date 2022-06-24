-- Keymappings
vim.api.nvim_set_keymap("n", "<TAB>", ":BufferNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-TAB>", ":BufferPrevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-x>", ":BufferClose<CR>", { noremap = true, silent = true })

-- Transparency
vim.cmd("hi BufferTabpageFill guibg=none")

-- vim.cmd "hi BufferInactive guibg=none"
-- vim.cmd "hi BufferInactiveIndex guibg=none"
-- vim.cmd "hi BufferInactiveMod guibg=none"
-- vim.cmd "hi BufferInactiveSign guibg=none"
-- vim.cmd "hi BufferInactiveTarget guibg=none"

-- vim.cmd "hi BufferCurrentIndex guibg=none"
-- vim.cmd "hi BufferCurrentMod guibg=none"
-- vim.cmd "hi BufferCurrentSign guibg=none"
-- vim.cmd "hi BufferCurrentTarget guibg=none"
-- vim.cmd "hi BufferVisible guibg=none"
-- vim.cmd "hi BufferVisibleIndex guibg=none"
-- vim.cmd "hi BufferVisibleMod guibg=none"
-- vim.cmd "hi BufferVisibleSign guibg=none"
-- vim.cmd "hi BufferVisibleTarget guibg=none"
