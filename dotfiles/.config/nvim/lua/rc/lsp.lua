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

  -- Check if required tools are available
  if fn.executable("cmake") == 0 then
    print("ERROR: cmake not found. Please install cmake first.")
    return false, nil
  end
  if fn.executable("make") == 0 then
    print("ERROR: make not found. Please install build tools first.")
    return false, nil
  end
  if fn.executable("git") == 0 then
    print("ERROR: git not found. Please install git first.")
    return false, nil
  end
  if fn.executable("clang") == 0 and fn.executable("gcc") == 0 then
    print("ERROR: No C++ compiler found. Please install clang or gcc.")
    return false, nil
  end

  if fn.isdirectory(src .. "/.git") ~= 1 then
    print("Cloning ccls repository...")
    local clone_result = fn.system(("git clone --recursive https://github.com/MaskRay/ccls.git %s"):format(src))
    if vim.v.shell_error ~= 0 then
      print("ERROR: Failed to clone ccls repository")
      return false, nil
    end
  end
  
  print("Configuring ccls with cmake...")
  local cmake_cmd = ("cd %s && cmake %s -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%s -DCMAKE_CXX_COMPILER=clang++ 2>&1"):format(build, src, root)
  local cmake_result = fn.system(cmake_cmd)
  if vim.v.shell_error ~= 0 then
    print("ERROR: cmake configuration failed. Output:")
    print(cmake_result)
    print("You may need to install: clang, llvm-dev, libclang-dev, rapidjson-dev")
    return false, nil
  end
  
  print("Building ccls (this may take a while)...")
  local make_cmd = ("cd %s && make -j$(nproc)"):format(build)
  local make_result = fn.system(make_cmd)
  if vim.v.shell_error ~= 0 then
    print("ERROR: make build failed")
    return false, nil
  end
  
  print("Installing ccls...")
  local install_cmd = ("cd %s && make install"):format(build)
  local install_result = fn.system(install_cmd)
  if vim.v.shell_error ~= 0 then
    print("ERROR: make install failed")
    return false, nil
  end
  
  if fn.executable(bin) == 1 then
    print("ccls installed successfully!")
    return true, bin
  else
    print("ERROR: ccls installation failed - binary not found")
    return false, nil
  end
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
