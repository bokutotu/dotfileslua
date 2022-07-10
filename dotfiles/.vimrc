set relativenumber
set number
set nocompatible
filetype plugin on

" statusバーにファイルのパスなどを表示する
" set noruler
" set laststatus=2
" set statusline+=%F
" set statusline+="%f%m%r%h%w [%Y] [0x%02.2B]%< %F%=%4v,%4l %3p%% of %L"
set statusline=
" Path to file (head)
set statusline+=%{expand('%:h')}/
" Switch color
set statusline+=%#Keyword#
" File name (tail)
set statusline+=%t

" 1行あたり80文字超えたラインでハイライトする
let &colorcolumn=join(range(120,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn="80,".join(range(100,999),",")

"highlight ColorColumn guibg=#202020 ctermbg=yellow

" 検索パターンが一致する時候補すべてハイライト
set hlsearch

"" インデントが空白で行われる
set expandtab

" 検索する時大文字小文字区別しない
set ignorecase

" 検索途中でもハイライトされる
set incsearch

" 大文字を含む検索では大文字を無視しない
set smartcase

" よくわからん
" set nocompatible

"yank した文字列をクリップボードにコピー
set clipboard=unnamed  

" シンタックスハイライトをon
" syntax on

" xで削除した時はヤンクしない
vnoremap x "_x
nnoremap x "_x

" いまいる場所を強調
" 行を強調表示
set cursorline

" 列を強調表示
set cursorcolumn

" jpでescと保存になる
inoremap <silent> jk <ESC>:w<CR>

" ESC 二回でハイライト削除
nnoremap <ESC><ESC> :nohlsearch<CR>

" <space>wで保存
nnoremap <silent><Space>w :w<CR>

" 編集中でもバッファの移動できるようにする
set hidden

" インデントを良い感じにする
" set autoindent
set tabstop=4
" JS or HTMLの時だけTab幅を変える
augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufNewFile,BufRead *.cu setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.c  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.cpp  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.rb setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.tsx setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.ts setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.html setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.css setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.json setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile *.tex setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" プラグインごとのキーマップ
" fzf & ripgrep
nnoremap <C-b> :Buffers<CR>
nnoremap <C-g> :Rg<Space>
nnoremap <leader><leader> :Commands<CR>
nnoremap <C-p> :call FzfOmniFiles()<CR>

