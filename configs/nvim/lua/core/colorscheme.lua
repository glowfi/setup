-- Settings
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

-- Line Number Highlight
vim.cmd("set cursorline")
vim.cmd("highlight clear CursorLine")
vim.cmd("highlight CursorLineNR guifg=#fabd2f guibg=none ctermbg=none ctermfg=none")

-- Transparency
vim.cmd("hi! Normal ctermbg=NONE guibg=NONE")
vim.cmd("hi! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE")
vim.cmd("hi! SignColumn ctermbg=none guibg=none")
vim.cmd("hi! NormalNC ctermbg=none guibg=none")
vim.cmd("hi! MsgArea ctermbg=none guibg=none")
vim.cmd("hi! TelescopeBorder ctermbg=none guibg=none")

-- LspDiagnostics
vim.cmd("hi! DiagnosticSignError  ctermbg=none guibg=none guifg=#fb4934")
vim.cmd("hi! DiagnosticSignWarn  ctermbg=none guibg=none guifg=#fabd2f")
vim.cmd("hi! DiagnosticSignHint  ctermbg=none guibg=none guifg=#8ec07c")
vim.cmd("hi! DiagnosticSignInfo  ctermbg=none guibg=none guifg=#83a598")

-- Gitsigns
vim.cmd("hi! GitSignsAdd     ctermbg=none guibg=none guifg=#b8bb26")
vim.cmd("hi! GitSignsChange  ctermbg=none guibg=none guifg=#83a598")
vim.cmd("hi! GitSignsDelete  ctermbg=none guibg=none guifg=#fb4934")

-- CursorLine
-- vim.cmd("set cursorline")
-- vim.cmd("hi CursorLine gui=underline cterm=underline")
