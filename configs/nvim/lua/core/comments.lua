-- Settings
require('nvim_comment').setup({
    comment_empty = false,
    hook = function()
        require("ts_context_commentstring.internal").update_commentstring()
    end
})

-- Keymappings
vim.api.nvim_set_keymap('n', '<C-_>', ":CommentToggle<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<C-_>', ":CommentToggle<CR>",
                        {noremap = true, silent = true})
