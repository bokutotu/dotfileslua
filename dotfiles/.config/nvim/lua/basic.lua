-- 相対的な行を表示
vim.opt.relativenumber = true

-- 現在いる業を表示
vim.opt.number = true

-- file 形式ごとにプラグインを有効化する
vim.api.nvim_set_option('filetype', 'on')

-- ステータスラインを整える
-- vim.api.nvim_command('set statusline=%!SetStatusLine()')

-- 100 行を超えたら画面の色を変える
vim.api.nvim_command('let &colorcolumn=join(range(120,999),",")')

-- 80行のところの色を変える
vim.api.nvim_command('let &colorcolumn="80,".join(range(100,999),",")')

-- 変わる色の設定
vim.api.nvim_command('highlight ColorColumn ctermbg=235 guibg=#2c2d27')

-- 検索結果を全てハイライト
vim.opt.hlsearch = true

-- インデントを空白で行う
vim.opt.expandtab = true

-- 検索は大文字小文字を無視する
vim.opt.ignorecase = true

-- でも大文字が入ったらそれは無視しない
vim.opt.smartcase = true

-- 検索途中もハイライト
vim.opt.incsearch = true

-- yanc to clipborad
-- vim.api.nvim_command('set clipborad=unnamed')
vim.g.clipborad = unnamed

-- -- xで系した場合は not yank
-- -- vim.opt.vnoremap = x
-- -- vim.opt.nnoremap = x
-- vnormap = 

-- 今いる行と列を強調
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- jkで保存, jjjでesc
vim.api.nvim_command('inoremap <silent> jk <ESC>:w<CR>')
vim.api.nvim_command('inoremap <silent> jjj <ESC><CR>')

-- esc x 2でハイライト解除
vim.api.nvim_command('nnoremap <ESC><ESC> :nohlsearch<CR>')

-- <space>wで保存
vim.api.nvim_command('nnoremap <silent><Space>w :w<CR>')

-- インデント
vim.api.nvim_command('set smartindent')
vim.api.nvim_command('set tabstop=4')

-- 画面分割系統
vim.api.nvim_command('nnoremap sj <C-w>j')
vim.api.nvim_command('nnoremap sk <C-w>k')
vim.api.nvim_command('nnoremap sl <C-w>l')
vim.api.nvim_command('nnoremap sh <C-w>h')
vim.api.nvim_command('nnoremap ss :<C-u>sp<CR><C-w>j')
vim.api.nvim_command('nnoremap sv :<C-u>vs<CR><C-w>l')

-- color schemt
vim.api.nvim_command('colorscheme hybrid')
vim.api.nvim_command('set background=dark')
