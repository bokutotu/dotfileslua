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

-- Define the reload function separately so it can reference itself
local function reload_all()
    -- Save all buffers
    vim.cmd('wa')
    
    -- Save current buffer info
    local current_buf = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local filetype = vim.bo.filetype
    
    -- Disable treesitter for all buffers before clearing
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            pcall(vim.treesitter.stop, buf)
        end
    end
    
    -- Clear all buffer-local autocommands and variables
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            -- Clear buffer-local autocommands
            vim.api.nvim_clear_autocmds({ buffer = buf })
            -- Clear buffer variables
            for k, _ in pairs(vim.b[buf] or {}) do
                vim.b[buf][k] = nil
            end
        end
    end
    
    -- Store all loaded modules before unloading
    local all_loaded_modules = {}
    for name, _ in pairs(package.loaded) do
        table.insert(all_loaded_modules, name)
    end
    
    -- Clear all global autocommands
    vim.cmd('autocmd!')
    
    -- Clear all treesitter related caches and state
    vim.treesitter._parsers = {}
    vim.treesitter._queries = {}
    if vim._ts_parsers then
        vim._ts_parsers = {}
    end
    if vim._ts_query_cache then
        vim._ts_query_cache = {}
    end
    
    -- Clear highlight namespace used by treesitter
    local ts_hl_ns = vim.api.nvim_get_namespaces()['treesitter/highlighter']
    if ts_hl_ns then
        vim.api.nvim_buf_clear_namespace(0, ts_hl_ns, 0, -1)
    end
    
    -- Unload ALL non-vim internal modules
    for _, name in ipairs(all_loaded_modules) do
        -- Keep only vim internal modules and lua standard library
        if not (name:match('^vim%.') or name:match('^vim$') or name:match('^_G') or name:match('^package') or name:match('^string') or name:match('^table') or name:match('^math') or name:match('^os') or name:match('^io') or name:match('^debug') or name:match('^coroutine') or name:match('^bit')) then
            package.loaded[name] = nil
        end
    end
    
    -- Clear all user commands
    vim.cmd('comclear')
    
    -- Clear all keymaps
    vim.cmd('mapclear')
    vim.cmd('mapclear!')
    vim.cmd('imapclear')
    vim.cmd('vmapclear')
    vim.cmd('xmapclear')
    vim.cmd('smapclear')
    vim.cmd('omapclear')
    vim.cmd('nmapclear')
    vim.cmd('cmapclear')
    vim.cmd('tmapclear')
    
    -- Clear highlights
    vim.cmd('highlight clear')
    
    -- Clear and reset options
    vim.cmd('set all&')
    vim.cmd('filetype off')
    vim.cmd('syntax off')
    
    -- Source init.lua again
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/init.lua')
    
    -- Properly reinitialize the buffer
    vim.defer_fn(function()
        vim.cmd('filetype plugin indent on')
        vim.cmd('syntax enable')
        
        -- Switch away and back to force full reinitialization
        if vim.api.nvim_buf_is_valid(current_buf) then
            -- Create a temporary empty buffer
            local temp_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_set_current_buf(temp_buf)
            
            -- Switch back to original buffer
            vim.defer_fn(function()
                vim.api.nvim_set_current_buf(current_buf)
                -- Force filetype detection
                if filetype and filetype ~= '' then
                    vim.bo.filetype = ''  -- Clear first
                    vim.defer_fn(function()
                        vim.bo.filetype = filetype  -- Then set to trigger FileType autocmds
                        -- Explicitly start treesitter for the buffer
                        vim.defer_fn(function()
                            pcall(vim.treesitter.start, current_buf, filetype)
                        end, 50)
                    end, 10)
                else
                    vim.cmd('filetype detect')
                end
                -- Delete temporary buffer
                vim.api.nvim_buf_delete(temp_buf, { force = true })
                -- Restore cursor position
                pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
                print('Neovim configuration reloaded!')
            end, 50)
        end
    end, 200)
end

-- Reload Neovim command
vim.api.nvim_create_user_command('ReloadAll', reload_all, { desc = 'Reload all Neovim configuration without restarting' })
