" 1. Core Settings & Initialization
set nocompatible
filetype off

" Setup cache directories
let s:cache_dir = expand('~/.vim/.cache')
if !isdirectory(s:cache_dir)
    call mkdir(s:cache_dir, 'p')
endif

" 2. Modern Plugin Management (Using vim-plug)
" Install vim-plug if not present: 
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plugged')

" Essentials
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'

" Language Support
Plug 'klen/python-mode', { 'for': 'python' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'

" UI / Colorschemes
Plug 'altercation/vim-colors-solarized'
Plug 'tomasr/molokai'
Plug 'nanotech/jellybeans.vim'

call plug#end()

" 3. Base Configuration
syntax enable                " Moved up to ensure it loads
filetype plugin indent on    " Essential for Python/JS 

set encoding=utf-8
set history=10000
set hidden                   " Switch buffers without saving [cite: 9]
set autoread                 " Reload files changed outside Vim [cite: 9]
set clipboard=unnamedplus    " Modern clipboard sync

" Formatting [cite: 11, 12, 13]
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set backspace=indent,eol,start

" Searching [cite: 16]
set incsearch
set hlsearch
set ignorecase
set smartcase

" 4. UI Configuration [cite: 19, 20]
set number
set cursorline
set laststatus=2
set showmatch
let g:solarized_termcolors=256
colorscheme solarized
set background=dark

" 5. Custom Functions (Keeping your logic)
function! Preserve(command)
    let _s=@/
    let l = line(".")
    let c = col(".")
    execute a:command
    let @/=_s
    call cursor(l, c)
endfunction

function! StripTrailingWhitespace()
    call Preserve("%s/\\s\\+$//e")
endfunction

" 6. Key Mappings [cite: 60, 62, 70]
let mapleader = ","
nnoremap <leader>w :w<cr>
inoremap jk <esc>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Filetype specific overrides [cite: 78, 80]
autocmd FileType python setlocal foldmethod=indent
autocmd FileType make setlocal noexpandtab

" Fix for jedi-vim recursion error
let g:jedi#auto_initialization = 0
let g:jedi#popup_on_dot = 0
