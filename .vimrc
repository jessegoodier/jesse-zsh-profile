syntax on
set tabstop=2
set shiftwidth=2
" set autoindent
set paste
" set expandtab
set ruler
set wildmenu
set title
set display+=lastline
set encoding=utf-8
set scrolloff=1
set sidescrolloff=5
set smartcase
set hlsearch

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" folding can help troubleshoot indentation syntax
set foldenable
set foldlevelstart=20
set foldmethod=indent
nnoremap <space> za

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent
let g:indentLine_char = '⦙'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
" packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
" https://www.arthurkoziel.com/setting-up-vim-for-yaml/
