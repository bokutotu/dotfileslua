local api = vim.api

--──────────────────────────────────────────────────────────────
-- 1. key-map helper
--──────────────────────────────────────────────────────────────
local function map(mode, lhs, rhs, opt)
  local o = { noremap = true, silent = true }
  if opt then o = vim.tbl_extend('force', o, opt) end
  vim.keymap.set(mode, lhs, rhs, o)
end

--──────────────────────────────────────────────────────────────
-- 2. diagnostics popup (<leader>rd)
--──────────────────────────────────────────────────────────────
api.nvim_create_autocmd('FileType', {
  pattern = { 'haskell', 'lhaskell', 'cabal' },
  callback = function()
    map('n', '<leader>rd',
      function() vim.diagnostic.open_float { scope = 'line', border = 'rounded' } end,
      { buffer = true })
  end,
})

--──────────────────────────────────────────────────────────────
-- 3. go-to-definition（HLS → fast-tags fallback）
--──────────────────────────────────────────────────────────────
local function goto_def()
  local enc = (vim.lsp.get_clients()[1] or {}).offset_encoding or 'utf-8'
  local pos = vim.lsp.util.make_position_params(nil, enc)
  local res = vim.lsp.buf_request_sync(0, 'textDocument/definition', pos, 250)
  if res then
    for _, v in pairs(res) do
      if v.result and not vim.tbl_isempty(v.result) then
        vim.lsp.util.jump_to_location(v.result[1], enc)
        return
      end
    end
  end
  vim.cmd('silent! tag ' .. vim.fn.expand('<cword>'))
end
map('n', '<F12>', goto_def)
map('n', '<S-F12>', '<C-t>')

--──────────────────────────────────────────────────────────────
-- 4. 保存時フォーマット : fourmolu → stylish-haskell
--──────────────────────────────────────────────────────────────
local function echo_err(tag, lines)
  api.nvim_echo({ { tag .. ': ' .. table.concat(lines, '\n'), 'ErrorMsg' } }, false, {})
end

local function strip_loaded(lines)
  local out = {}
  for _, l in ipairs(lines) do
    if not l:match('^Loaded config from') then
      table.insert(out, l)
    end
  end
  return out
end

local function format_hs(bufnr)
  bufnr = bufnr or 0
  local file = api.nvim_buf_get_name(bufnr); if file == '' then return end

  if vim.fn.executable('fourmolu') ~= 1 then
    echo_err('format-hs', { 'fourmolu not found in PATH' }); return
  end

  -- 現内容
  local src = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

  -- ❶ fourmolu
  local four = vim.fn.systemlist(
    { 'fourmolu', '--stdin-input-file', file },
    src
  )
  if vim.v.shell_error ~= 0 then
    echo_err('fourmolu', four); return
  end
  four = strip_loaded(four)

  -- ❷ stylish-haskell（ある場合のみ）
  local styl
  if vim.fn.executable('stylish-haskell') == 1 then
    styl = vim.fn.systemlist({ 'stylish-haskell' }, table.concat(four, '\n'))
    if vim.v.shell_error ~= 0 then
      echo_err('stylish-haskell', styl); return
    end
  else
    styl = four
  end

  -- 反映
  local old = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if table.concat(styl, '\n') ~= table.concat(old, '\n') then
    local view = vim.fn.winsaveview()
    api.nvim_buf_set_lines(bufnr, 0, -1, false, styl)
    vim.fn.winrestview(view)
  end
end

api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.hs', '*.lhs' },
  callback = function(a) format_hs(a.buf) end,
})

--──────────────────────────────────────────────────────────────
-- 5. HLS（診断・補完のみ、フォーマッタ無効）
--──────────────────────────────────────────────────────────────
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').hls.setup {
  cmd = { 'haskell-language-server', '--lsp' },
  capabilities = capabilities,
  root_dir = require('lspconfig.util')
               .root_pattern('hie.yaml', '*.cabal', 'stack.yaml', '.git'),
  on_attach = function(client, bufnr)
    -- Disable HLS formatting to avoid conflicts with custom formatter
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  settings = {
    haskell = {
      diagnosticsOnChange = true,
      checkParents        = 'CheckOnSave',
      formattingProvider  = 'none',
      plugin = {
        fourmolu            = { globalOn = false },
        ['stylish-haskell'] = { globalOn = false },
        hlint               = { globalOn = true },
      },
    },
  },
}

--──────────────────────────────────────────────────────────────
-- 6. fast-tags 自動再生成
--──────────────────────────────────────────────────────────────
vim.o.tags = './.tags;,./**/*.tags'
api.nvim_create_autocmd('BufWritePost', {
  group   = api.nvim_create_augroup('HsTags', { clear = true }),
  pattern = { '*.hs', '*.lhs', '*.cabal' },
  callback = function()
    if vim.fn.executable('fast-tags') == 1 then
      vim.fn.jobstart({ 'fast-tags', '-R', '.' }, { detach = true })
    end
  end,
})

