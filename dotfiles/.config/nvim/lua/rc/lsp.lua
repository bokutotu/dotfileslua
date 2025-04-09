-- Check if ccls exists, if not, build it
local function ensure_ccls_installed()
  local nvim_data_dir = vim.fn.stdpath('data')
  local ccls_bin_dir = nvim_data_dir .. "/ccls/bin"
  local ccls_path = ccls_bin_dir .. "/ccls"
  
  if vim.fn.executable(ccls_path) ~= 1 then
    print("ccls not found. Installing ccls...")
    local build_dir = nvim_data_dir .. "/ccls/build"
    local source_dir = nvim_data_dir .. "/ccls/src"
    
    -- Create directories if they don't exist
    vim.fn.mkdir(ccls_bin_dir, "p")
    vim.fn.mkdir(build_dir, "p")
    vim.fn.mkdir(source_dir, "p")
    
    -- Check if the repo exists
    if vim.fn.isdirectory(source_dir .. "/.git") ~= 1 then
      -- Clone the repo with submodules
      vim.fn.system("cd " .. source_dir .. " && git clone --recursive git@github.com:MaskRay/ccls.git .")
    end
    
    -- Build ccls
    local build_cmd = "cd " .. build_dir .. " && cmake " .. source_dir .. " -DCMAKE_INSTALL_PREFIX=" .. nvim_data_dir .. "/ccls && make -j && make install"
    print("Building ccls with command: " .. build_cmd)
    vim.fn.system(build_cmd)
    
    if vim.fn.executable(ccls_path) ~= 1 then
      print("Failed to build ccls.")
      return false
    else
      print("ccls successfully built at: " .. ccls_path)
      return true, ccls_path
    end
  end
  
  return true, ccls_path
end

-- Ensure ccls is installed before proceeding
local use_ccls, ccls_path = ensure_ccls_installed()

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
    "ts_ls",  -- 例: TypeScript 用
    "hls",    -- 例: Haskell 用
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
-- (A) C/C++ 言語サーバー設定（ccls）
--------------------------------------------------------------------------------

-- 1) root_dir を決定する関数:
--    .git があるディレクトリまでさかのぼり、なければ現在の作業ディレクトリを返す
local function cpp_find_root_dir(fname)
  local git_dir = util.find_git_ancestor(fname)
  if git_dir then
    return git_dir
  end
  -- .git が見つからなければ vim を開いているディレクトリをルートに
  return vim.fn.getcwd()
end

-- 簡素化したccls設定
local ccls_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { ccls_path },
  root_dir = cpp_find_root_dir,
}

--------------------------------------------------------------------------------
-- (B) Metals (Scala) インストール確認 & セットアップ用関数
--------------------------------------------------------------------------------
local function ensure_metals_installed()
  if vim.fn.executable("metals") == 1 then
    return true -- 既にインストール済み
  end

  print("Metals not found. Attempting to install using coursier...")
  -- coursier が PATH にあることを前提とする
  local cmd = "cs install metals"
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    print("Failed to install Metals using coursier. Please install it manually or ensure 'cs' is in your PATH.")
    print("Coursier output:\n" .. output)
    return false
  end

  -- 再度確認
  if vim.fn.executable("metals") == 1 then
    print("Metals successfully installed via coursier.")
    return true
  else
    print("Installation command seemed successful, but 'metals' executable not found. Check coursier setup.")
    print("Coursier output:\n" .. output)
    return false
  end
end

--------------------------------------------------------------------------------
-- (C) ts_ls (TypeScript) の設定 (例)
--------------------------------------------------------------------------------

local ts_ls_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
}

--------------------------------------------------------------------------------
-- (C) Metals (Scala) の設定 (lspconfig で直接)
--------------------------------------------------------------------------------
local metals_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  -- Metals はプロジェクトルートの検出に build.sbt や .metals ディレクトリなどを利用します
  root_dir = util.root_pattern("build.sbt", ".metals", "pom.xml", "build.sc"),
  -- 必要に応じて Metals 固有の設定を追加
  -- settings = { ... }
  -- cmd = { "path/to/metals" } -- PATHが通っていない場合など
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

  -- ts_ls: 個別設定
  ["ts_ls"] = function()
    lspconfig.ts_ls.setup(ts_ls_setup)
  end,
})

-- ccls の設定（Mason 経由ではない）
if use_ccls then
  lspconfig.ccls.setup(ccls_setup)
end

-- Metals の設定 (lspconfig で直接) - インストール確認後
if ensure_metals_installed() then
  lspconfig.metals.setup(metals_setup)
end

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
