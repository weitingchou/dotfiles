" 1. Core Settings & Initialization
set nocompatible
filetype off

" Setup cache directories
let s:cache_dir = expand('~/.vim/.cache')
if !isdirectory(s:cache_dir)
    call mkdir(s:cache_dir, 'p')
endif

" 2. Modern Plugin Management (Using vim-plug)
" For Vim:    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" For Neovim: curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if has('nvim')
    call plug#begin('~/.local/share/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

" Essentials
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'

" Language Support
" Vim-only Python plugins (neovim uses LSP instead)
if !has('nvim')
    Plug 'klen/python-mode', { 'for': 'python' }
    Plug 'davidhalter/jedi-vim', { 'for': 'python' }
endif
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'

" Neovim-only: Python LSP + completion (nvim 0.11+ native LSP, no lspconfig needed)
if has('nvim')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
endif

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
silent! colorscheme solarized
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

" Fix for jedi-vim recursion error (vim only)
if !has('nvim')
    let g:jedi#auto_initialization = 0
    let g:jedi#popup_on_dot = 0
endif

" 7. Neovim LSP + Completion (Python via Pyright)
if has('nvim')
lua << EOF
-- Completion setup (guard against missing plugins during initial install)
local ok_cmp, cmp = pcall(require, 'cmp')
local ok_luasnip, luasnip = pcall(require, 'luasnip')
if not (ok_cmp and ok_luasnip) then return end

cmp.setup({
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>']      = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }),
})

-- Pyright LSP (nvim 0.11+ native API - no nvim-lspconfig required)
local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
vim.lsp.config['pyright'] = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'pyrightconfig.json', '.git' },
    capabilities = ok_cmp_lsp and cmp_nvim_lsp.default_capabilities() or nil,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = 'basic',
                autoSearchPaths  = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
}
vim.lsp.enable('pyright')

-- LSP key mappings
local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,   opts)  -- Go to definition
vim.keymap.set('n', 'gr',         vim.lsp.buf.references,   opts)  -- Find references
vim.keymap.set('n', 'K',          vim.lsp.buf.hover,        opts)  -- Hover docs
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,       opts)  -- Rename symbol
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,  opts)  -- Code actions
vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev, opts)  -- Prev diagnostic
vim.keymap.set('n', ']d',         vim.diagnostic.goto_next, opts)  -- Next diagnostic
EOF
endif
