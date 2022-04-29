-- Disable compatibility with vi which can cause unexpected issues.
vim.cmd("set nocompatible")

-- Enable type file detection. Vim will be able to try to detect the type of file in use.
vim.cmd("filetype on")

-- Enable plugins and load plugin for the detected file type.
vim.cmd("filetype plugin on")

-- Indent Settings
vim.bo.smartindent = true
vim.cmd("filetype plugin indent on")
vim.cmd("set copyindent")
vim.cmd("set colorcolumn=99999")

-- Turn syntax highlighting on.
vim.cmd("syntax on")

-- Add numbers to each line on the left-hand side.
vim.cmd("set number")

-- Enable relative numbering
-- vim.wo.relativenumber = true

-- Set shift width to 4 spaces.
vim.cmd("set shiftwidth=4")

-- Set tab width to 4 columns.
vim.cmd("set tabstop=4")

-- Use space characters instead of tabs.
vim.cmd("set expandtab")

-- Disable swap and backup
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Set undo directory
vim.o.undodir = CACHE_PATH .. "/undo"

-- Enable persistent undo
vim.o.undofile = true

-- Do not let cursor scroll below or above N number of lines when scrolling.
vim.cmd("set scrolloff=10")

-- Display long lines as just one line
vim.cmd("set nowrap")

-- More space for displaying messages
vim.o.cmdheight = 2

-- Makes popup menu smaller
vim.o.pumheight = 10

-- While searching though a file incrementally highlight matching characters as you type.
vim.cmd("set incsearch")

-- Ignore capital letters during search.
vim.cmd("set ignorecase")

-- Override the ignorecase option if searching for capital letters.
vim.cmd("set smartcase")

-- Show partial command you type in the last line of the screen.
vim.cmd("set showcmd")

-- Show the mode you are on the last line.
vim.cmd("set noshowmode")

-- Show matching words during a search.
vim.cmd("set showmatch")

-- Use highlighting when doing a search.
vim.cmd("set hlsearch")

-- Set the commands to save in history default number is 20.
vim.cmd("set history=1000")

-- Enable auto completion menu after pressing TAB.
vim.cmd("set wildmenu")

-- Wildmenu will ignore files with these extensions.
vim.cmd("set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx")

-- Required to keep multiple buffers open multiple buffers
vim.o.hidden = true

-- Title settings
vim.o.title = true
vim.o.titlestring = "%<%F%=%l/%L - nvim"
TERMINAL = vim.fn.expand("$TERMINAL")
vim.cmd('let &titleold="' .. TERMINAL .. '"')

-- Modifying split bars to transparent
vim.cmd("set fillchars+=vert:\\ ")
vim.cmd("highlight VertSplit guibg=White guifg=Black ctermbg=6 ctermfg=0")

-- Detect when a file is changed
vim.cmd("set autoread")

-- treat dash separated words as a word text object"
vim.cmd("set iskeyword+=-")

-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess:append("c")

-- Make substitution work in realtime
vim.cmd("set inccommand=split")

-- Horizontal splits will automatically be below
vim.o.splitbelow = true

-- Vertical splits will automatically be to the right
vim.o.splitright = true

-- Copy paste between vim and everything else
vim.o.clipboard = "unnamedplus"

-- Set terminal true colors
vim.cmd("set termguicolors")

-- Enable mouse support
vim.o.mouse = "a"

-- Disables a sql error
vim.cmd("let g:omni_sql_no_default_maps = 1")
