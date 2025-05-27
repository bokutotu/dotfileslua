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
