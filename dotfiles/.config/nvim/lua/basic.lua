vim.lsp.buf.format { async = true }

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
vim.g.clipboard = unnamed

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
-- vim.api.nvim_command('colorscheme hybrid')
vim.api.nvim_command('colorscheme onedark')
vim.api.nvim_command('set background=dark')

vim.api.nvim_command("set fileformats=unix,dos,mac")
vim.api.nvim_command("set fileencodings=utf-8,sjis")

vim.api.nvim_command("set tags=.tags;")

-- Reload Neovim command
vim.api.nvim_create_user_command('ReloadAll', function()
    -- Save all buffers
    vim.cmd('wa')
    
    -- Save window dimensions
    local lines = vim.o.lines
    local columns = vim.o.columns
    
    -- Clear all autocommands
    vim.cmd('autocmd!')
    
    -- Store list of loaded plugin modules before clearing
    local plugin_modules = {}
    for name, _ in pairs(package.loaded) do
        -- Capture all non-config modules that might be plugins
        if not (name:match('^basic') or name:match('^plugins') or name:match('^rc') or name:match('^indent')) then
            -- Store plugin modules to potentially reload them
            if name:match('^[a-z]') and not name:match('^vim') and not name:match('^nvim') then
                table.insert(plugin_modules, name)
            end
        end
    end
    
    -- Unload all loaded Lua modules from our config
    for name, _ in pairs(package.loaded) do
        if name:match('^basic') or name:match('^plugins') or name:match('^rc') or name:match('^indent') then
            package.loaded[name] = nil
        end
    end
    
    -- Unload packer compiled file
    package.loaded['packer_compiled'] = nil
    
    -- Don't clear mappings - let plugins re-register them properly
    -- This prevents loss of plugin mappings that aren't re-created on setup()
    
    -- Source init.lua again
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/init.lua')
    
    -- Force re-source the packer compiled file to ensure all plugin configs are loaded
    vim.defer_fn(function()
        local packer_compiled = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua'
        if vim.fn.filereadable(packer_compiled) == 1 then
            vim.cmd('source ' .. packer_compiled)
        end
        
        -- Automatically discover and re-require all rc modules
        local rc_path = vim.fn.stdpath('config') .. '/lua/rc'
        local rc_files = vim.fn.glob(rc_path .. '/*.lua', false, true)
        
        for _, file in ipairs(rc_files) do
            local module_name = 'rc.' .. vim.fn.fnamemodify(file, ':t:r')
            package.loaded[module_name] = nil
            pcall(require, module_name)
        end
        
        print('Neovim configuration reloaded!')
    end, 100)
end, { desc = 'Reload all Neovim configuration without restarting' })
