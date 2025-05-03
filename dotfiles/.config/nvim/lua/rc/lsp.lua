--------------------------------------------------------------------------------
-- rc/lsp.lua – Neovim 0.10+ 専用（inlay-hint 新 API 使用）
--------------------------------------------------------------------------------
local fn, api = vim.fn, vim.api
local lspconfig   = require("lspconfig")
local util        = require("lspconfig.util")
local capabilities= require("cmp_nvim_lsp").default_capabilities()
local on_attach   = function() end  -- ここにキー設定などを足す

-- =============================================================================
-- 0. ヘルパー
-- =============================================================================
local function ensure_ccls_installed()
  local data      = fn.stdpath("data")
  local root      = data .. "/ccls"
  local bin       = root .. "/bin/ccls"
  if fn.executable(bin) == 1 then return true, bin end

  print("ccls not found. Installing…")
  local src, build = root .. "/src", root .. "/build"
  fn.mkdir(src, "p") ; fn.mkdir(build, "p")

  if fn.isdirectory(src .. "/.git") ~= 1 then
    fn.system(("git clone --recursive git@github.com:MaskRay/ccls.git %s"):format(src))
  end
  local cmd = ("cd %s && cmake %s -DCMAKE_INSTALL_PREFIX=%s && make -j && make install")
           :format(build, src, root)
  print("Building ccls:\n  " .. cmd) ; fn.system(cmd)
  return fn.executable(bin) == 1 and {true, bin} or {false}
end

local function ensure_metals_installed()
  if fn.executable("metals") == 1 then return true end
  print("Metals not found. Installing with coursier…")
  local out = fn.system("cs install metals")
  if vim.v.shell_error ~= 0 or fn.executable("metals") ~= 1 then
    print("Metals install failed:\n" .. out) ; return false
  end
  return true
end

-- =============================================================================
-- 1. Mason（※ HLS は完全除外）
-- =============================================================================
require("mason").setup({
  ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
})
require("mason-lspconfig").setup({
  ensure_installed       = { "ts_ls" },       -- Mason 管理に任せるのはこれだけ
  automatic_installation = { exclude = { "hls" } },  -- HLS をスキップ
})

-- =============================================================================
-- 2. LSPConfig – 個別に手動セットアップ
-- =============================================================================
-- 2.1 C/C++
local have_ccls, ccls_bin = ensure_ccls_installed()
if have_ccls then
  lspconfig.ccls.setup({
    cmd          = { ccls_bin },
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir     = function(fname) return util.find_git_ancestor(fname) or fn.getcwd() end,
  })
end

-- 2.2 TypeScript
lspconfig.ts_ls.setup({
  on_attach    = on_attach,
  capabilities = capabilities,
  filetypes    = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
})

-- 2.3 Haskell  (PATH 上のバイナリをそのまま使用)
lspconfig.hls.setup({
  cmd          = { "haskell-language-server", "--lsp" }, -- wrapper を使うなら名前を変更
  on_attach    = on_attach,
  capabilities = capabilities,
  root_dir     = util.root_pattern("*.cabal", "stack.yaml", "hie.yaml",
                                   ".ghci", "package.yaml"),
  filetypes    = { "haskell", "lhaskell" },
})

-- 2.4 Metals
if ensure_metals_installed() then
  lspconfig.metals.setup({
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir     = util.root_pattern("build.sbt", ".metals", "pom.xml", "build.sc"),
  })
end

-- =============================================================================
-- 3. AutoCmd
-- =============================================================================
-- Inlay hints – Neovim 0.10+ API
api.nvim_create_autocmd("LspAttach", {
  group = api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { buf = ev.buf })
    end
  end,
})
