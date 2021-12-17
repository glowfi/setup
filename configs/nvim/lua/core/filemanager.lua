-- Settings
require("nnn").setup({
    command = "nnn -d -e",
    session = "local",
    set_default_mappings = 0,
    replace_netrw = 1
})

vim.cmd "let g:nnn#layout = { 'window': { 'width': 0.6, 'height': 0.6, 'highlight': 'Debug' } }"

-- Keymappings
vim.cmd "nnoremap <silent><leader>nn :NnnPicker %:p:h<CR>"
