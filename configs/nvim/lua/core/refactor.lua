-- Settings
local status_ok, refactor = pcall(require, "refactoring")
if not status_ok then return end

refactor.setup({})

-- Load refactoring Telescope extension
require("telescope").load_extension("refactoring")

-- Remap to open the Telescope refactoring menu in visual mode
vim.api.nvim_set_keymap("v", "<leader>rr",
                        "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
                        {noremap = true})

-- Keymappings
vim.api.nvim_set_keymap("v", "<Leader>re",
                        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
                        {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<Leader>rf",
                        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
                        {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<Leader>rv",
                        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
                        {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<Leader>ri",
                        [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
                        {noremap = true, silent = true, expr = false})
