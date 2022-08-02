-- Leader key
vim.cmd("let mapleader = ' '")

-- Remapping vertical split.
vim.api.nvim_set_keymap("n", "<Leader>v", ":vsplit<cr>", { silent = true })

-- Remapping horizontal split.
vim.api.nvim_set_keymap("n", "<Leader>h", ":split<cr>", { silent = true })

-- Quit Current window.
vim.api.nvim_set_keymap("n", "<c-q>", ":quit<cr>", { silent = true })

-- Save current file.
vim.api.nvim_set_keymap("n", "<S-s>", ":w<cr>", { silent = true })

-- Replace all instance in normal mode of selected word.
vim.api.nvim_set_keymap("n", "<Leader>r", ":%s///g<Left><Left>", { silent = true })

-- Replace all instance in visual mode of selected word.Can be used to select a range of lines to replace words.
vim.cmd('vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>')

-- Clear search highlights.
vim.api.nvim_set_keymap("n", "<c-Space>", ':let @/=""<CR>', { silent = true })

-- Map Ctrl-Backspace to delete the previous word in insert mode.
vim.cmd("noremap! <C-BS> <C-w>")
vim.cmd("noremap! <C-h> <C-w>")

-- Window movements
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { silent = true })

-- Resize split windows using arrow keys by pressing.
vim.api.nvim_set_keymap("n", "<M-Up>", ":resize +2<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<M-Down>", ":resize -2<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<M-Left>", ":vertical resize -2<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<M-Right>", ":vertical resize +2<CR>", { silent = true })

-- Move selected line / block of text in visual mode
vim.api.nvim_set_keymap("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })

-- Copy all to clipboard
vim.api.nvim_set_keymap("n", "<Leader>y", ":%y+<cr>", { noremap = true, silent = true })

-- Select all
vim.api.nvim_set_keymap("n", "<c-a>", "ggVG", { noremap = true, silent = true })

-- Insert special characters
vim.cmd("inoremap <c-a> ä")
vim.cmd("inoremap <m-a> Ä")
vim.cmd("inoremap <c-o> ö")
vim.cmd("inoremap <m-o> Ö")
vim.cmd("inoremap <c-u> ü")
vim.cmd("inoremap <m-u> Ü")
vim.cmd("inoremap <c-b> ß")

-- Disable Completion
vim.api.nvim_set_keymap(
	"n",
	"<Leader>l",
	":lua require('cmp').setup { enabled = false }<CR>:LspStop<CR>",
	{ noremap = true, silent = true }
)
