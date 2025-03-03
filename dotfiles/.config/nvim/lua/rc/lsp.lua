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

-- ccls の設定
local function ccls_on_new_config(new_config, new_root_dir)
  -- Check for .ccls config file
  local ccls_config_path = new_root_dir .. "/.ccls"
  local ccls_yaml_path = new_root_dir .. "/.ccls.yaml"
  local ccls_json_path = new_root_dir .. "/.ccls.json"
  
  -- Set init_options if they don't exist
  if not new_config.init_options then
    new_config.init_options = {}
  end
  
  -- Load .ccls file (compilation database format)
  if vim.fn.filereadable(ccls_config_path) == 1 then
    print("Loading ccls config from: " .. ccls_config_path)
    -- Let ccls know to look for the .ccls file
    new_config.init_options.compilationDatabaseDirectory = new_root_dir
    new_config.init_options.compilationDatabaseCommand = "cat " .. ccls_config_path
  end
  
  -- Load .ccls.yaml if it exists
  if vim.fn.filereadable(ccls_yaml_path) == 1 then
    print("Loading ccls config from: " .. ccls_yaml_path)
    -- File exists, tell ccls to use it
    new_config.init_options.configFile = ccls_yaml_path
  end
  
  -- Load .ccls.json if it exists (higher priority than yaml)
  if vim.fn.filereadable(ccls_json_path) == 1 then
    print("Loading ccls config from: " .. ccls_json_path)
    -- File exists, tell ccls to use it
    new_config.init_options.configFile = ccls_json_path
  end
end

local ccls_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { ccls_path },
  root_dir = cpp_find_root_dir,
  on_new_config = ccls_on_new_config,
  init_options = {
    cache = {
      directory = vim.fn.stdpath('cache') .. "/ccls-cache",
    },
    clang = {
      excludeArgs = { "-frounding-math" },
    },
  },
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

  -- ts_ls: 個別設定
  ["ts_ls"] = function()
    lspconfig.ts_ls.setup(ts_ls_setup)
  end,
})

-- ccls の設定（Mason 経由ではない）
if use_ccls then
  lspconfig.ccls.setup(ccls_setup)
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

