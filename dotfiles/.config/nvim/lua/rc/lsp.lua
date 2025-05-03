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
-- 4. hsc2hs 自動生成 → LSP を .hs に付け替える
-- =============================================================================
local function hsc2hs_generate(src_path)
  -- 出力は: 同ディレクトリ、先頭に「._」を付けた隠しファイル
  local out_path = vim.fs.dirname(src_path) .. "/._" .. vim.fs.basename(src_path) .. ".hs"
  local ok = vim.fn.system({ "hsc2hs", "-o", out_path, src_path })
  if vim.v.shell_error ~= 0 then
    vim.notify("hsc2hs failed: " .. ok, vim.log.levels.ERROR)
    return nil
  end
  return out_path
end

-- .hsc を開いた瞬間に一度生成 & LSP アタッチ
api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.hsc",
  callback = function(ev)
    local hs = hsc2hs_generate(ev.file)
    if not hs then return end         -- 生成失敗

    -- 開いていなければ隠しバッファで読み込み
    local hs_buf = vim.fn.bufnr(hs, true)
    if not vim.api.nvim_buf_is_loaded(hs_buf) then
      vim.fn.bufload(hs_buf)
    end

    -- HLS を .hs にアタッチ（まだなら）
    if not next(vim.lsp.get_active_clients({bufnr = hs_buf})) then
      lspconfig.hls.manager.try_add(hs_buf)
    end
  end,
})

-- .hsc を保存するたびに再生成 → LSP へ didSave を送る
api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.hsc",
  callback = function(ev)
    local hs = hsc2hs_generate(ev.file)
    if not hs then return end
    -- :checktime 相当で LSP 側に更新通知
    local hs_buf = vim.fn.bufnr(hs, true)
    if vim.api.nvim_buf_is_loaded(hs_buf) then
      vim.api.nvim_buf_call(hs_buf, function()
        vim.cmd("edit!")  -- reload silently
      end)
    end
  end,
})

-- LspAttach: .hsc では inlayHint を送らず、生成 .hs は通常通り
api.nvim_create_autocmd("LspAttach", {
  group = api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    if vim.bo[bufnr].filetype ~= "haskell" then
      return               -- .hsc などはスキップ (.hs だけ処理)
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { buf = bufnr })
    end
  end,
})
