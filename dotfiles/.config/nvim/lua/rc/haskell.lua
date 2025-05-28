local api = vim.api

-- キーマップ補助
local function map(m, lhs, rhs, opt)
  local o = { noremap = true, silent = true }
  if opt then o = vim.tbl_extend("force", o, opt) end
  vim.keymap.set(m, lhs, rhs, o)
end

-- <leader>rd で行単位の診断ポップアップ
api.nvim_create_autocmd("FileType", {
  pattern = { "haskell", "lhaskell" },
  callback = function()
    map("n", "<leader>rd",
      function() vim.diagnostic.open_float({ scope = "line", border = "rounded" }) end,
      { buffer = true })
  end,
})

---------------------------------------------------------------------
-- ❶ フォーマッタ（imports 整理込み）
---------------------------------------------------------------------
local function format_hls(bufnr)
  -- imports の整理
  local enc = (vim.lsp.get_clients({ bufnr = bufnr })[1] or {}).offset_encoding or "utf-8"
  local p   = vim.lsp.util.make_range_params(nil, enc)
  p.context = { only = { "source.organizeImports" } }
  vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", p, 1000)

  -- stylish-haskell で本体フォーマット
  vim.lsp.buf.format { bufnr = bufnr, async = false, timeout_ms = 5000 }
end

---------------------------------------------------------------------
-- ❷ 定義ジャンプ（LSP → tags）
---------------------------------------------------------------------
local function goto_def()
  local enc = (vim.lsp.get_clients()[1] or {}).offset_encoding or "utf-8"
  local p   = vim.lsp.util.make_position_params(nil, enc)
  local r   = vim.lsp.buf_request_sync(0, "textDocument/definition", p, 400)
  if r then
    for _, v in pairs(r) do
      if v.result and not vim.tbl_isempty(v.result) then
        vim.lsp.util.jump_to_location(v.result[1], enc)
        return
      end
    end
  end
  vim.cmd("silent! tag " .. vim.fn.expand("<cword>"))
end

map("n", "<F12>",   goto_def)
map("n", "<S-F12>", "<C-t>")

---------------------------------------------------------------------
-- ❸ LSP 起動設定
---------------------------------------------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    api.nvim_create_autocmd("BufWritePost", {
      group   = api.nvim_create_augroup("HLSFmt", { clear = true }),
      buffer  = bufnr,
      callback = function() format_hls(bufnr) end,
    })
  end
end

-- tags ファイル検索パス
vim.o.tags = "./.tags;,./**/*.tags"

---------------------------------------------------------------------
-- ❹ haskell-tools.nvim 設定
---------------------------------------------------------------------
vim.g.haskell_tools = {
  hls = {
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir     = require("lspconfig.util").root_pattern("hie.yaml", "*.cabal", "stack.yaml", ".git"),
    settings = {
      haskell = {
        diagnosticsOnChange = false,
        checkParents        = "CheckOnSave",

        -- ★★ ここで provider を指定 ★★
        formattingProvider  = "stylish-haskell",

        plugin = {
          ["stylish-haskell"] = { globalOn = true },
          fourmolu            = { globalOn = false },
          ormolu              = { globalOn = false },
          hlint               = { globalOn = true },
        },
      },
    },
  },
  tools = {
    generate_tags = true,
    codeLens      = { autoRefresh = false },
  },
}


