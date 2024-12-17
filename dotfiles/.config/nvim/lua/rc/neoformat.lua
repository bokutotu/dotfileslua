-- Neoformatでrustfmtにエディション2021を指定
vim.g.neoformat_rust_rustfmt = {
    exe = "rustfmt",
    args = {"--edition", "2021"},
    stdin = 1
}

-- Rust用の自動フォーマット設定
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.cmd("Neoformat")
  end,
  group = vim.api.nvim_create_augroup("rust_format", { clear = true }),
})

-- Neoformatの詳細な出力を有効にする
-- vim.g.neoformat_verbose = 1

-- Rustに対して有効なフォーマッタをrustfmtに設定
vim.g.neoformat_enabled_rust = { "rustfmt" }
