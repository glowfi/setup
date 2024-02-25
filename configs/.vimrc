" __     _____ __  __ ____   ____ 
" \ \   / /_ _|  \/  |  _ \ / ___|
"  \ \ / / | || |\/| | |_) | |    
"   \ V /  | || |  | |  _ <| |___ 
"    \_/  |___|_|  |_|_| \_\\____|


"""" SETTINGS """

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Indent Settings
set smartindent
filetype plugin indent on
set copyindent
set colorcolumn=99999

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Disable swap and backup
set nobackup
set nowritebackup
set noswapfile

" Set undo directory
set undodir=~/.cache/undo-vim

" Enable persistent undo
set undofile

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Display long lines as just one line
set nowrap

" More space for displaying messages
set cmdheight=2

" Makes popup menu smaller
set pumheight=10

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set noshowmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Required to keep multiple buffers open multiple buffers
set hidden

" Title settings
set title
set titlestring ="%<%F%=%l/%L - vim"
let &titleold="$TERMINAL"

" Modifying split bars to transparent
set fillchars+=vert:\\ 
highlight VertSplit guibg=White guifg=Black ctermbg=6 ctermfg=0

" Detect when a file is changed
set autoread

" treat dash separated words as a word text object"
set iskeyword+=-

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Make substitution work in realtime
" set inccommand=nosplit

" Horizontal splits will automatically be below
set splitbelow

" Vertical splits will automatically be to the right
set splitright

" Copy paste between vim and everything else
function Func2X11()
:call system('xclip -selection c', @r)
endfunction
vnoremap <C-c> "ry:call Func2X11()<cr>

" Set terminal true colors
set termguicolors

" Enable mouse support
set mouse=a

" Disables a sql error
let g:omni_sql_no_default_maps = 1

" Line Number Highlight
set cursorline
highlight clear CursorLine
highlight LineNR guifg=#fabd2f 


"""" KEYMAPS """

" Leader key
let mapleader = ' '

" Remapping vertical split.
nnoremap <silent> <Leader>v :vsplit<CR>

" Remapping horizontal split.
nnoremap <silent> <Leader>h :split<CR>

" Quit Current window.
nnoremap <silent> <c-q> :quit<CR>

" Save current file.
nnoremap <silent> <S-s> :w<cr>

" Replace all instance in normal mode of selected word.
nnoremap <silent> <Leader>r :%s///g<Left><Left><CR>

" Replace all instance in visual mode of selected word.Can be used to select a range of lines to replace words.
vnoremap <Leader>r hy:%s/<C-r>h//gc<left><left><left>

" Clear search highlights.
nnoremap <silent> <c-Space> :let @/=""<CR>

" Map Ctrl-Backspace to delete the previous word in insert mode.
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

" Window movements
nnoremap <silent> <c-h> <C-w>h
nnoremap <silent> <c-h> <C-w>j
nnoremap <silent> <c-h> <C-w>k
nnoremap <silent> <c-h> <C-w>l

" Resize split windows using arrow keys by pressing.
nnoremap <silent> <M-Up> :resize +2<CR>
nnoremap <silent> <M-Down> :resize -2<CR>
nnoremap <silent> <M-Left> :resize -2<CR>
nnoremap <silent> <M-Right> :resize +2<CR>

" Move selected line / block of text in visual mode
xnoremap <silent> <K> :move '<-2<CR>gv-gv
xnoremap <silent> <J> :move '>+1<CR>gv-gv

" Copy all to clipboard
nnoremap <silent> <Leader>y :%y+<cr><CR>

" Select all
nnoremap <silent> <c-a> ggVG

" Insert special characters
inoremap <c-a> ä
inoremap <m-a> Ä
inoremap <c-o> ö
inoremap <m-o> Ö
inoremap <c-u> ü
inoremap <m-u> Ü
inoremap <c-b> ß


""" PLUG PLUGIN MANAGER

let vimplug_exists=expand('~/.vim/autoload/plug.vim')
if has('win32')&&!has('win64')
  let curl_exists=expand('C:\Windows\Sysnative\curl.exe')
else
  let curl_exists=expand('curl')
endif


if !filereadable(vimplug_exists)
  if !executable(curl_exists)
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!"curl_exists" -fLo " . shellescape(vimplug_exists) . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif


""" PLUGINS LIST

call plug#begin()
Plug 'morhetz/gruvbox'
call plug#end()

""" GRUVBOX SETTINGS """
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark
let g:airline_theme='gruvbox'
