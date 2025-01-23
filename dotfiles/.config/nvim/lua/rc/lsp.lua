vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
-- (1) Mason / Mason-Lspconfig のセットアップ
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
})

local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = {
    "clangd",
    "ts_ls",  -- 例: TypeScript 用
    "hls",
  },
  automatic_installation = true,
})

-- (2) LSPConfig
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

-- on_attach: 他プラグインでキーマップ設定している想定なので最小限
local on_attach = function(client, bufnr)
  -- 必要ならここでキーマップなどを設定
end

-- nvim-cmp (cmp-nvim-lsp) を使うなら capabilities を拡張
local capabilities = require("cmp_nvim_lsp").default_capabilities()


--------------------------------------------------------------------------------
-- (A) clangd の設定
--------------------------------------------------------------------------------

-- 1) root_dir を決定する関数:
--    .git があるディレクトリまでさかのぼり、なければ現在の作業ディレクトリを返す
local function clangd_find_config_dir(fname)
  local git_dir = util.find_git_ancestor(fname)
  if git_dir then
    return git_dir
  end
  -- .git が見つからなければ vim を開いているディレクトリをルートに
  return vim.fn.getcwd()
end

-- 2) 新しいコンフィグが生成されるたびに呼ばれ、--config=... を付与する
--    .clangd ファイルが存在すればそれを clangd に渡す
local function clangd_on_new_config(new_config, new_root_dir)
  local config_path = new_root_dir .. "/.clangd"
  if vim.fn.filereadable(config_path) == 1 then
    -- new_config.cmd が未定義なら初期化する
    if not new_config.cmd then
      new_config.cmd = { "clangd" }
    end
    -- --config= で明示的に .clangd を指定
    table.insert(new_config.cmd, "--enable-config")
  end
end

local clangd_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  -- ↑で定義した関数を root_dir に使う
  root_dir = clangd_find_config_dir,
  on_new_config = clangd_on_new_config,
}


--------------------------------------------------------------------------------
-- (B) ts_ls (TypeScript) の設定 (例)
--------------------------------------------------------------------------------

local ts_ls_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
}


--------------------------------------------------------------------------------
-- (3) mason-lspconfig.setup_handlers
--------------------------------------------------------------------------------

mason_lspconfig.setup_handlers({
  -- デフォルトハンドラ: 個別指定していないサーバ
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,

  -- clangd: 個別設定
  ["clangd"] = function()
    lspconfig.clangd.setup(clangd_setup)
  end,

  -- ts_ls: 個別設定
  ["ts_ls"] = function()
    lspconfig.ts_ls.setup(ts_ls_setup)
  end,
})


--------------------------------------------------------------------------------
-- (4) LspAttach イベント (inlay hint など)
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf
    if type(vim.lsp.inlay_hint) == "function"
       and client
       and client.server_capabilities
       and client.server_capabilities.inlayHintProvider
    then
      vim.lsp.inlay_hint(bufnr, true)
    end
  end,
})

