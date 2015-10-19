
" default settings {{{
    " initialize default settings
    let s:settings = {}
    let s:settings.default_indent = 4
    let s:settings.max_column = 120
    let s:settings.autocomplete_method = 'neocomplcache'
    let s:settings.colorscheme = 'solarized'
    let s:settings.enable_cursorcolumn = 0

    let s:cache_dir = '~/.vim/.cache'
"}}}

" setup & neobundle {{{
    set nocompatible
    set all&    "reset everything to their defaults
    set runtimepath+=~/.vim/bundle/neobundle.vim/
    call neobundle#begin(expand('~/.vim/bundle/'))
    NeoBundleFetch 'Shougo/neobundle.vim'
"}}}

" functions {{{
    function! s:get_cache_dir(suffix) "{{{
        return resolve(expand(s:cache_dir . '/' . a:suffix))
    endfunction "}}}
    function! Source(begin, end) "{{{
        let lines = getline(a:begin, a:end)
        for line in lines
            execute line
        endfor
    endfunction "}}}
    function! Preserve(command) "{{{
        " preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        execute a:command
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction "}}}
    function! StripTrailingWhitespace() "{{{
        call Preserve("%s/\\s\\+$//e")
    endfunction "}}}
    function! EnsureExists(path) "{{{
        if !isdirectory(expand(a:path))
            call mkdir(expand(a:path))
        endif
    endfunction "}}}
    function! CloseWindowOrKillBuffer() "{{{
        let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

        " never bdelete a nerd tree
        if matchstr(expand("%"), 'NERD') == 'NERD'
            wincmd c
            return
        endif

        if number_of_windows_to_this_buffer > 1 
            wincmd c
        else
            bdelete
        endif
    endfunction "}}}
"}}}

" base configuration {{{
    set timeoutlen=300          "mapping timeout
    set ttimeoutlen=50          "keycode timeout

    "set fileencodings=utf-8,big5,euc-jp,gbk,euc-kr,utf-bom,iso8859-1 
    set encoding=utf-8          "set encoding for text
    set history=10000
    set ttyfast                 "assume fast terminal connection
    if exists('$TMUX')
        set clipboard=
    else
        set clipboard=unnamed   "sync with OS clipboard
    endif

    set hidden                  "allow you switch files without saving them
    set autoread                "auto reload if file saved externally
    set fileformats+=mac        "add mac to auto-detection of file format line
    set nrformats-=octal        "always assume decimal numbers
    set showcmd                 "show (partial) command in the last line of the screen
    set tags=tags:/
    set showfulltag
    set modeline
    set modelines=5

    set noshelltemp             "use pipes

    set cmdheight=1             "Number of screen lines to use for the command-line
    set viminfo='10000,\"10000
    set autochdir

    " whitespace
    set backspace=indent,eol,start                      "allow backspacing everything in insert mode
    set autoindent                                      "automatically indent to match adjacent lines
    set expandtab                                       "spaces instead of tabs
    set smarttab                                        "use shiftwidth to enter tabs
    let &tabstop=s:settings.default_indent              "number of spaces per tab for display
    let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
    let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
    set list                                            "highlight whitespace
    set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
    set shiftround
    set linebreak
    let &showbreak='↪ '

    set scrolloff=1                                     "always show content after scroll
    set scrolljump=5                                    "minimum number of lines to scroll
    set display+=lastline
    set wildmenu                                        "show list for autocomplete
    set wildmode=list:full
    set wildignorecase

    set splitbelow
    set splitright

    " disable sounds
    set noerrorbells
    set novisualbell
    set t_vb=

    " searching
    set incsearch           "incremental searching
    set hlsearch            "highlight searching
    set ignorecase          "ignore case for searching
    set smartcase           "do case-sensitive if there's a capital letter
    if executable('ag')
        set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
        set grepformat=%f:%l:%c:%m
    endif

    " vim file/folder management {{{
        " persistent undo
        if exists('+undofile')
            set undofile
            let &undodir = s:get_cache_dir('undo')
        endif

        " backups
        set backup
        let &backupdir = s:get_cache_dir('backup')

        " swap files
        let &directory = s:get_cache_dir('swap')
        set noswapfile

        call EnsureExists(s:cache_dir)
        call EnsureExists(&undodir)
        call EnsureExists(&backupdir)
        call EnsureExists(&directory)
    "}}}

    let mapleader = ","         " Map <Leader> to , key
    let g:mapleader = ","
"}}}

" ui configuration {{{
    set showmatch               "automatically highlight matching braces/brackets/etc.
    set matchtime=2             "tens of a second to show matching parentheses
    set number
    set lazyredraw
    set laststatus=2
    set noshowmode
    set foldenable              "enable folds by default
    set foldmethod=syntax       "fold via syntax of files
    set foldlevelstart=99       "open all folds by default
    let g:xml_syntax_folding=1  "enable xml folding

    set cursorline
    autocmd WinLeave * setlocal nocursorline
    autocmd WinEnter * setlocal cursorline
    let &colorcolumn=s:settings.max_column
    if s:settings.enable_cursorcolumn
        set cursorcolumn
        autocmd WinLeave * setlocal nocursorcolumn
        autocmd WinEnter * setlocal cursorcolumn
    endif

    if has('conceal')
        set conceallevel=1
        set listchars+=conceal:Δ
    endif

    if has('gui_running')
        " open maximized
        set lines=999 columns=9999
        if s:is_windows
        autocmd GUIEnter * simalt ~x
        endif

        set guioptions+=t                                 "tear off menu items
        set guioptions-=T                                 "toolbar icons

        if s:is_macvim
            set gfn=Ubuntu_Mono:h14
            set transparency=2
        endif

        if s:is_windows
            set gfn=Ubuntu_Mono:h10
        endif

        if has('gui_gtk')
            set gfn=Ubuntu\ Mono\ 11
        endif
    else
        if $COLORTERM == 'gnome-terminal'
            set t_Co=256 "why you no tell me correct colors?!?!
        endif
        if $TERM_PROGRAM == 'iTerm.app'
            " different cursors for insert vs normal mode
            if exists('$TMUX')
                let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
                let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
            else
                let &t_SI = "\<Esc>]50;CursorShape=1\x7"
                let &t_EI = "\<Esc>]50;CursorShape=0\x7"
            endif
        endif
    endif
"}}}


" plugin/mapping configuration {{{
    " Core
    NeoBundle 'matchit.zip'
    NeoBundle 'bling/vim-airline' "{{{
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#left_sep = ' '
        let g:airline#extensions#tabline#left_alt_sep = '¦'
        let g:airline_detect_paste = 1
        let g:airline_powerline_fonts = 1
        let g:airline_theme = s:settings.colorscheme
    "}}}
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'tpope/vim-repeat'
    NeoBundle 'tpope/vim-dispatch'
    NeoBundle 'tpope/vim-eunuch'
    NeoBundle 'Shougo/vimproc.vim', {
        \ 'build': {
            \ 'mac': 'make -f make_mac.mak',
            \ 'unix': 'make -f make_unix.mak',
            \ 'cygwin': 'make -f make_cygwin.mak',
            \ 'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
        \ },
    \ }

    " Javascript
    NeoBundle 'marijnh/tern_for_vim', {
        \ 'autoload': { 'filetypes': ['javascript'] },
        \ 'build': {
            \ 'mac': 'npm install',
            \ 'unix': 'npm install',
            \ 'cygwin': 'npm install',
            \ 'windows': 'npm install',
        \ },
    \ }
    NeoBundle 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
    NeoBundle 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}} "{{{
        nnoremap <leader>fjs :call JsBeautify()<cr>
    "}}}
    NeoBundle 'leafgarland/typescript-vim', {'autoload':{'filetypes':['typescript']}}
    NeoBundle 'kchmck/vim-coffee-script', {'autoload':{'filetypes':['coffee']}}
    NeoBundle 'mmalecki/vim-node.js', {'autoload':{'filetypes':['javascript']}}
    NeoBundle 'leshill/vim-json', {'autoload':{'filetypes':['javascript','json']}}
    NeoBundle 'othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','coffee','ls','typescript']}}

    " Ruby
    NeoBundle 'tpope/vim-rails'
    NeoBundle 'tpope/vim-bundler'

    " Python
    NeoBundle 'klen/python-mode', {'autoload':{'filetypes':['python']}} "{{{
        let g:pymode_rope=0
    "}}}
    NeoBundle 'davidhalter/jedi-vim', {'autoload':{'filetypes':['python']}} "{{{
        let g:jedi#popup_on_dot=0
    "}}}

    " Go
    NeoBundle 'jnwhiteh/vim-golang', {'autoload':{'filetypes':['go']}}
    NeoBundle 'nsf/gocode', {'autoload': {'filetypes':['go']}, 'rtp': 'vim'}

    " C/C++
    NeoBundle 'brookhong/cscope.vim.git', {'autoload':{'filetypes':['c', 'cpp']}} "{{{
        if has('cscope')
            set csprg=/usr/bin/cscope
            set csto=1
            set cst
            set nocsverb
            " add any database in current directory
            if filereadable("cscope.out")
                cs add cscope.out
            endif
            set csverb
        endif
        "s: find this c symbol
        "g: find this definition
        "d: find functions called by this function
        "c: find functions calling this function
        "t: find this text string
        "e: find this egrep pattern
        "f: find this file
        "i: find files #include this file
        nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR> 
        nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
        nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    "}}}
    NeoBundle 'STL-Syntax'

    " autocomplete
    NeoBundle 'honza/vim-snippets'
    NeoBundle 'Shougo/neosnippet-snippets'
    NeoBundle 'Shougo/neosnippet.vim' "{{{
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
        let g:neosnippet#enable_snipmate_compatibility=1

        imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
    "}}}
    NeoBundle 'Shougo/neocomplcache.vim', {'autoload':{'insert':1}} "{{{
        let g:neocomplcache_enable_at_startup=1
        let g:neocomplcache_temporary_dir=s:get_cache_dir('neocomplcache')
        let g:neocomplcache_enable_fuzzy_completion=1
    "}}}

    " editing
    NeoBundle 'editorconfig/editorconfig-vim', {'autoload':{'insert':1}}
    NeoBundle 'tpope/vim-endwise'
    NeoBundle 'tpope/vim-speeddating'
    NeoBundle 'thinca/vim-visualstar'
    NeoBundle 'tomtom/tcomment_vim'
    NeoBundle 'terryma/vim-expand-region'
    NeoBundle 'terryma/vim-multiple-cursors'
    NeoBundle 'chrisbra/NrrwRgn'
    NeoBundle 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
        nmap <Leader>a& :Tabularize /&<CR>
        vmap <Leader>a& :Tabularize /&<CR>
        nmap <Leader>a= :Tabularize /=<CR>
        vmap <Leader>a= :Tabularize /=<CR>
        nmap <Leader>a: :Tabularize /:<CR>
        vmap <Leader>a: :Tabularize /:<CR>
        nmap <Leader>a:: :Tabularize /:\zs<CR>
        vmap <Leader>a:: :Tabularize /:\zs<CR>
        nmap <Leader>a, :Tabularize /,<CR>
        vmap <Leader>a, :Tabularize /,<CR>
        nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
        vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "}}}
    NeoBundle 'jiangmiao/auto-pairs'
    NeoBundle 'justinmk/vim-sneak' "{{{
        let g:sneak#streak = 1
    "}}}

    " git
    NeoBundle 'tpope/vim-fugitive' "{{{
        nnoremap <silent> <leader>gs :Gstatus<CR>
        nnoremap <silent> <leader>gd :Gdiff<CR>
        nnoremap <silent> <leader>gc :Gcommit<CR>
        nnoremap <silent> <leader>gb :Gblame<CR>
        nnoremap          <leader>ge :Gedit<space>
        nnoremap <silent> <leader>gl :silent Glog<CR>:copen<CR>
        nnoremap <silent> <leader>gp :Git push<CR>
        nnoremap <silent> <leader>gw :Gwrite<CR>
        nnoremap <silent> <leader>gr :Gremove<CR>
        autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
        autocmd BufReadPost fugitive://* set bufhidden=delete
    "}}}

    " docker
    NeoBundle 'https://github.com/ekalinin/Dockerfile.vim.git'

    " navigation
    NeoBundle 'mileszs/ack.vim' "{{{
        if executable('ag')
            let g:ackprg = "ag --nogroup --column --smart-case --follow"
        endif
    "}}}
    NeoBundle 'mbbill/undotree', {'autoload':{'commands':'UndotreeToggle'}} "{{{
        let g:undotree_WindowLayout='botright'
        let g:undotree_SetFocusWhenToggle=1
        nnoremap <silent> <F5> :UndotreeToggle<CR>
    "}}}
    NeoBundle 'EasyGrep', {'autoload':{'commands':'GrepOptions'}} "{{{
        let g:EasyGrepRecursive=1
        let g:EasyGrepAllOptionsInExplorer=1
        let g:EasyGrepCommand=1
        nnoremap <leader>vo :GrepOptions<cr>
    "}}}
    NeoBundle 'ctrlpvim/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
        let g:ctrlp_clear_cache_on_exit=1
        let g:ctrlp_max_height=40
        let g:ctrlp_show_hidden=0
        let g:ctrlp_follow_symlinks=1
        let g:ctrlp_max_files=20000
        let g:ctrlp_cache_dir=s:get_cache_dir('ctrlp')
        let g:ctrlp_reuse_window='startify'
        let g:ctrlp_extensions=['funky']
        let g:ctrlp_custom_ignore = {
            \ 'dir': '\v[\/]\.(git|hg|svn|idea)$',
            \ 'file': '\v\.DS_Store$'
        \ }

        if executable('ag')
            let g:ctrlp_user_command='ag %s -l --nocolor -g ""'
        endif

        nmap \ [ctrlp]
        nnoremap [ctrlp] <nop>

        nnoremap [ctrlp]t :CtrlPBufTag<cr>
        nnoremap [ctrlp]T :CtrlPTag<cr>
        nnoremap [ctrlp]l :CtrlPLine<cr>
        nnoremap [ctrlp]o :CtrlPFunky<cr>
        nnoremap [ctrlp]b :CtrlPBuffer<cr>
    "}}}
    NeoBundle 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}} "{{{
        let NERDTreeShowHidden=1
        let NERDTreeQuitOnOpen=0
        let NERDTreeShowLineNumbers=1
        let NERDTreeChDirMode=0
        let NERDTreeShowBookmarks=1
        let NERDTreeIgnore=['\.git','\.hg']
        let NERDTreeBookmarksFile=s:get_cache_dir('NERDTreeBookmarks')
        nnoremap <F2> :NERDTreeToggle<CR>
        nnoremap <F3> :NERDTreeFind<CR>
    "}}}

    " unite
    NeoBundle 'Shougo/unite.vim' "{{{
        let bundle = neobundle#get('unite.vim')
        function! bundle.hooks.on_source(bundle)
            call unite#filters#matcher_default#use(['matcher_fuzzy'])
            call unite#filters#sorter_default#use(['sorter_rank'])
            call unite#custom#source('line,outline','matchers','matcher_fuzzy')
            call unite#custom#profile('default', 'context', {
                \ 'start_insert': 1,
                \ 'direction': 'botright',
                \ })
        endfunction

        let g:unite_data_directory=s:get_cache_dir('unite')
        let g:unite_source_history_yank_enable=1
        let g:unite_source_rec_max_cache_files=5000

        if executable('ag')
            let g:unite_source_grep_command='ag'
            let g:unite_source_grep_default_opts='--nocolor --line-numbers --nogroup -S -C4'
            let g:unite_source_grep_recursive_opt=''
        endif

        function! s:unite_settings()
            nmap <buffer> Q <plug>(unite_exit)
            nmap <buffer> <esc> <plug>(unite_exit)
            imap <buffer> <esc> <plug>(unite_exit)
        endfunction
        autocmd FileType unite call s:unite_settings()

        nmap <space> [unite]
        nnoremap [unite] <nop>

        nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr>
        nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr>
        nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
        nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
        nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
        nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
        nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
        nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
        nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    "}}}
    NeoBundle 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
    NeoBundle 'osyo-manga/unite-airline_themes', {'autoload':{'unite_sources':'airline_themes'}} "{{{
        nnoremap <silent> [unite]a :<C-u>Unite -winheight=10 -auto-preview -buffer-name=airline_themes airline_themes<cr>
    "}}}
    NeoBundle 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources':'colorscheme'}} "{{{
        nnoremap <silent> [unite]c :<C-u>Unite -winheight=10 -auto-preview -buffer-name=colorschemes colorscheme<cr>
    "}}}
    NeoBundle 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}} "{{{
        nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tag tag tag/file<cr>
    "}}}
    NeoBundle 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
        nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
    "}}}
    NeoBundle 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}} "{{{
        nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>
    "}}}
    NeoBundle 'Shougo/junkfile.vim', {'autoload':{'commands':'JunkfileOpen','unite_sources':['junkfile','junkfile/new']}} "{{{
        let g:junkfile#directory=s:get_cache_dir('junk')
        nnoremap <silent> [unite]j :<C-u>Unite -auto-resize -buffer-name=junk junkfile junkfile/new<cr>
    "}}}

    " indents
    NeoBundle 'nathanaelkane/vim-indent-guides' "{{{
        let g:indent_guides_start_level=1
        let g:indent_guides_guide_size=1
        let g:indent_guides_enable_on_vim_startup=0
        let g:indent_guides_color_change_percent=3
        if !has('gui_running')
            let g:indent_guides_auto_colors=0
            function! s:indent_set_console_colors()
                hi IndentGuidesOdd ctermbg=235
                hi IndentGuidesEven ctermbg=236
            endfunction
            autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
        endif 
    "}}}  

    " misc
    if exists('%TMUX')
        NeoBundle 'christoomey/vim-tmux-navigator'
    endif
    NeoBundle 'kana/vim-vspec'
    NeoBundle 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}
    NeoBundle 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}
    if executable('redcarpet') && executable('instant-markdown-d')
        NeoBundle 'suan/vim-instant-markdown', {'autoload':{'filetypes':['markdown']}}
    endif
    NeoBundle 'guns/xterm-color-table.vim', {'autoload':{'commands':'XtermColorTable'}}
    NeoBundle 'chrisbra/vim_faq'
    NeoBundle 'vimwiki'
    NeoBundle 'bufkill.vim'
    NeoBundle 'mhinz/vim-startify' "{{{
        let g:startify_session_dir = s:get_cache_dir('sessions')
        let g:startify_change_to_vcs_root = 1 
        let g:startify_show_sessions = 1 
        nnoremap <F1> :Startify<cr>
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
        let g:syntastic_error_symbol = '✗' 
        let g:syntastic_style_error_symbol = '✠' 
        let g:syntastic_warning_symbol = '∆' 
        let g:syntastic_style_warning_symbol = '≈' 
    "}}}

    nnoremap <leader>nbu :Unite neobundle/update -vertical -no-start-insert<cr>
"}}}

" mappings {{{
    " formatting shortcuts
    nmap <leader>fef :call Preserve("normal gg=G")<CR>
    nmap <leader>f$ :call StripTrailingWhitespace()<CR>
    vmap <leader>s :sort<cr>

    " eval vimscript by line or visual selection
    nmap <silent> <leader>e :call Source(line('.'), line('.'))<CR>
    vmap <silent> <leader>e :call Source(line('v'), line('.'))<CR>

    nnoremap <leader>w :w<cr>

    " toggle paste
    map <F6> :set invpaste<CR>:set paste?<CR>

    " remap arrow keys
    nnoremap <left> :bprev<CR>
    nnoremap <right> :bnext<CR>
    nnoremap <up> :tabnext<CR>
    nnoremap <down> :tabprev<CR>


    " smash escape
    inoremap jk <esc>
    inoremap kj <esc>

    " change cursor position in insert mode
    inoremap <C-h> <left>
    inoremap <C-l> <right>

    inoremap <C-u> <C-g>u<C-u>

    if mapcheck('<space>/') == ''
        nnoremap <space>/ :vimgrep //gj **/*<left><left><left><left><left><left><left><left>
    endif

    " sane regex {{{
        nnoremap / /\v
        vnoremap / /\v
        nnoremap ? ?\v
        vnoremap ? ?\v
        nnoremap :s/ :s/\v
    "}}}

    " command-line window {{{
        nnoremap q: q:i
        nnoremap q/ q/i
        nnoremap q? q?i
    "}}}

    " folds {{{
        nnoremap zr zr:echo &foldlevel<cr>
        nnoremap zm zm:echo &foldlevel<cr>
        nnoremap zR zR:echo &foldlevel<cr>
        nnoremap zM zM:echo &foldlevel<cr>
    "}}}

    " screen line scroll
    nnoremap <silent> j gj
    nnoremap <silent> k gk

    " auto center {{{
        nnoremap <silent> n nzz
        nnoremap <silent> N Nzz
        nnoremap <silent> * *zz
        nnoremap <silent> # #zz
        nnoremap <silent> g* g*zz
        nnoremap <silent> g# g#zz
        nnoremap <silent> <C-o> <C-o>zz
        nnoremap <silent> <C-i> <C-i>zz
    "}}}

    " reselect visual block after indent
    vnoremap < <gv
    vnoremap > >gv

    " reselect last paste
    nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

    " find current word in quickfix
    nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
    " find last search in quickfix
    nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

    " shortcuts for windows {{{
        nnoremap <leader>v <C-w>v<C-w>l
        nnoremap <leader>s <C-w>s
        nnoremap <leader>vsa :vert sba<cr>
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
    "}}}

    " tab shortcuts
    map <leader>tn :tabnew<CR>
    map <leader>tc :tabclose<CR>

    " make Y consistent with C and D. See :help Y.
    nnoremap Y y$

    " hide annoying quit message
    nnoremap <C-c> <C-c>:echo<cr>

    " window killer
    nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

    " quick buffer open
    nnoremap gb :ls<cr>:e #

    if neobundle#is_sourced('vim-dispatch')
        nnoremap <leader>tag :Dispatch ctags -R<cr>
    endif

    " general
    nmap <leader>l :set list! list?<cr>
    nnoremap <BS> :set hlsearch! hlsearch?<cr>

    map <F8> :set number!<BAr>set number?<CR>
    map <F7> :set spell!<BAr>set spell?<CR>
    map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

    " helpers for profiling {{{
        nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
        nnoremap <silent> <leader>DP :exe ":profile pause"<cr>
        nnoremap <silent> <leader>DC :exe ":profile continue"<cr>
        nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>
  "}}}
"}}}

" powerline settings {{{
    set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim/
"}}}

" commands {{{
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
"}}}

" autocmd {{{
    " go back to previous position of cursor if any
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \  exe 'normal! g`"zvzz' |
        \ endif

    autocmd FileType js,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
    autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
    autocmd FileType python setlocal foldmethod=indent
    autocmd FileType markdown setlocal nolist
    autocmd FileType vim setlocal fdm=indent keywordprg=:help
    autocmd FileType make setlocal noexpandtab tabstop=4 "override tab settings for make files
                                                         "ie. use real tabs instead of spaces
"}}}

" color schemes {{{
    NeoBundle 'altercation/vim-colors-solarized' "{{{
        if has('gui_running')
            set background=light

            " I like the lower contrast for list characters.  But in a terminal
            " this makes them completely invisible and causes the cursor to
            " disappear.
            let g:solarized_visibility="low"    "Specifies contrast of invisibles.
        else
            set background=dark
        endif
        if $TERM == 'screen'
            let g:solarized_termcolors=256      "tell Solarized to use the 256 degraded color mode
        endif
        let g:solarized_termtrans=1
        highlight SignColumn guibg=#002b36
    "}}}
    NeoBundle 'nanotech/jellybeans.vim'
    NeoBundle 'tomasr/molokai'
    NeoBundle 'chriskempson/vim-tomorrow-theme'
    NeoBundle 'chriskempson/base16-vim'
    NeoBundle 'w0ng/vim-hybrid'
    NeoBundle 'sjl/badwolf'
    NeoBundle 'zeis/vim-kolor' "{{{
        let g:kolor_underlined=1
    "}}}
"}}}

" finish loading {{{
    call neobundle#end()
    filetype plugin indent on
    syntax enable
    exec 'colorscheme '.s:settings.colorscheme

    NeoBundleCheck
"}}}


