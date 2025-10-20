local api = vim.api
local capabilities = require('rc.capabilities').get()

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
-- 3. haskell-tools 設定
--──────────────────────────────────────────────────────────────
local function merge_haskell_tools_defaults(user_config)
  local defaults = {
    tools = {
      tags = {
        enable = true,
      },
    },
    hls = {
      capabilities = capabilities,
      default_settings = {
        haskell = {
          formattingProvider = 'none',
          plugin = {
            fourmolu = { globalOn = false },
            ['stylish-haskell'] = { globalOn = false },
            hlint = { globalOn = true },
          },
        },
      },
    },
  }

  if type(user_config) ~= 'table' then
    return defaults
  end

  return vim.tbl_deep_extend('force', defaults, user_config)
end

if type(vim.g.haskell_tools) == 'function' then
  local user_config_fn = vim.g.haskell_tools
  vim.g.haskell_tools = function()
    local ok, cfg = pcall(user_config_fn)
    if not ok then
      vim.notify('haskell-tools config error: ' .. cfg, vim.log.levels.ERROR)
      return merge_haskell_tools_defaults(nil)
    end
    return merge_haskell_tools_defaults(cfg)
  end
else
  vim.g.haskell_tools = merge_haskell_tools_defaults(vim.g.haskell_tools)
end

--──────────────────────────────────────────────────────────────
-- 4. 保存時フォーマット : fourmolu → stylish-haskell
--──────────────────────────────────────────────────────────────
local function echo_err(tag, lines)
  vim.notify(tag .. ': ' .. table.concat(lines, '\n'), vim.log.levels.ERROR)
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
  local file = api.nvim_buf_get_name(bufnr)
  if file == '' then return end

  if vim.fn.executable('fourmolu') ~= 1 then
    echo_err('format-hs', { 'fourmolu not found in PATH' })
    return
  end

  local src = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

  local four = vim.fn.systemlist(
    { 'fourmolu', '--stdin-input-file', file },
    src
  )
  if vim.v.shell_error ~= 0 then
    local err_lines = {}
    for i = 1, math.min(3, #four) do
      table.insert(err_lines, four[i])
    end
    if #four > 3 then
      table.insert(err_lines, '... (' .. (#four - 3) .. ' more lines)')
    end
    echo_err('fourmolu', err_lines)
    return
  end
  four = strip_loaded(four)

  local styl
  if vim.fn.executable('stylish-haskell') == 1 then
    styl = vim.fn.systemlist({ 'stylish-haskell' }, table.concat(four, '\n'))
    if vim.v.shell_error ~= 0 then
      local err_lines = {}
      for i = 1, math.min(3, #styl) do
        table.insert(err_lines, styl[i])
      end
      if #styl > 3 then
        table.insert(err_lines, '... (' .. (#styl - 3) .. ' more lines)')
      end
      echo_err('stylish-haskell', err_lines)
      return
    end
  else
    styl = four
  end

  local old = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if table.concat(styl, '\n') ~= table.concat(old, '\n') then
    local view = vim.fn.winsaveview()
    api.nvim_buf_set_lines(bufnr, 0, -1, false, styl)
    vim.fn.winrestview(view)
  end
end

--──────────────────────────────────────────────────────────────
-- 5. haskell-tools 連携用の buffer-local 設定
--──────────────────────────────────────────────────────────────
local format_group = api.nvim_create_augroup('HaskellToolsFormat', { clear = true })

api.nvim_create_autocmd('FileType', {
  group = format_group,
  pattern = { 'haskell', 'lhaskell' },
  callback = function(args)
    if vim.b.haskell_tools_attached then return end
    vim.b.haskell_tools_attached = true

    map('n', '<F12>', vim.lsp.buf.definition, { buffer = args.buf })
    map('n', '<S-F12>', '<C-t>', { buffer = args.buf })

    api.nvim_create_autocmd('BufWritePre', {
      group = format_group,
      buffer = args.buf,
      callback = function(ev) format_hs(ev.buf) end,
    })
  end,
})
