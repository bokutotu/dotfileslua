-- ============================================================================
-- Haskell (LSP only, no auto-formatter, no TAGS regeneration)
--   • Diagnostics popup:   <leader>rd
--   • Go to definition:    <F12>   (HLS → fast-tags fallback)
--   • Jump back:           <S-F12> (= <C-t>)
--   • 保存しても fast-tags などは **実行しません**（生成したい場合は下部の
--     ★ Optional: TAGS auto-regen ★ をアンコメントしてください）
-- ============================================================================

local api = vim.api

-- ──────────────────────────────────────────────────────────────────────────
-- 1. key-map helper
-- ──────────────────────────────────────────────────────────────────────────
local function map(mode, lhs, rhs, opt)
  local o = { noremap = true, silent = true }
  if opt then o = vim.tbl_extend('force', o, opt) end
  vim.keymap.set(mode, lhs, rhs, o)
end

-- ──────────────────────────────────────────────────────────────────────────
-- 2. diagnostics popup (<leader>rd)
-- ──────────────────────────────────────────────────────────────────────────
api.nvim_create_autocmd('FileType', {
  pattern = { 'haskell', 'lhaskell', 'cabal' },
  callback = function()
    map('n', '<leader>rd',
      function() vim.diagnostic.open_float({ scope = 'line', border = 'rounded' }) end,
      { buffer = true })
  end,
})

-- ──────────────────────────────────────────────────────────────────────────
-- 3. go-to-definition（HLS → fast-tags fallback）
-- ──────────────────────────────────────────────────────────────────────────
local function goto_def()
  local enc = (vim.lsp.get_clients()[1] or {}).offset_encoding or 'utf-8'
  local pos = vim.lsp.util.make_position_params(nil, enc)
  local res = vim.lsp.buf_request_sync(0, 'textDocument/definition', pos, 300)

  if res then
    for _, v in pairs(res) do
      if v.result and not vim.tbl_isempty(v.result) then
        vim.lsp.util.jump_to_location(v.result[1], enc)
        return
      end
    end
  end
  vim.cmd('silent! tag ' .. vim.fn.expand('<cword>'))  -- fast-tags fallback
end
map('n', '<F12>',   goto_def)
map('n', '<S-F12>', '<C-t>')

-- ──────────────────────────────────────────────────────────────────────────
-- 4. HLS-only LSP 設定（保存フックやフォーマッタは一切無し）
-- ──────────────────────────────────────────────────────────────────────────
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').hls.setup{
  cmd          = { 'haskell-language-server', '--lsp' },   -- nix: wrapper 不使用
  capabilities = capabilities,
  root_dir     = require('lspconfig.util')
                   .root_pattern('hie.yaml', '*.cabal', 'stack.yaml', '.git'),
  settings = {
    haskell = {
      diagnosticsOnChange = true,           -- 編集中にも診断を更新
      checkParents        = 'CheckOnSave',  -- 親モジュールは保存時にチェック
      formattingProvider  = 'none',         -- LSP 側フォーマット機能を無効化
      plugin = {
        fourmolu            = { globalOn = false },
        ['stylish-haskell'] = { globalOn = false },
        ormolu              = { globalOn = false },
        hlint               = { globalOn = true  },
      },
    },
  },
  on_attach = function() end,               -- 追加オートコマンド無し
}

-- ──────────────────────────────────────────────────────────────────────────
-- 5. TAGS 検索パス（生成はしない）
-- ──────────────────────────────────────────────────────────────────────────
vim.o.tags = './.tags;,./**/*.tags'

-- local function regen_tags()
--   if vim.fn.executable('fast-tags') == 1 then
--     vim.fn.jobstart({ 'fast-tags', '-R', '.' }, { detach = true })
--   end
-- end
-- api.nvim_create_autocmd('BufWritePost', {
--   group    = api.nvim_create_augroup('HsTags', { clear = true }),
--   pattern  = { '*.hs', '*.lhs', '*.cabal' },
--   callback = regen_tags,
-- })

