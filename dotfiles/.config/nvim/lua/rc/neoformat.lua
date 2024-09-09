-- Rust用の自動フォーマット設定
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.cmd("undojoin | Neoformat")
  end,
  group = vim.api.nvim_create_augroup("rust_format", { clear = true }),
})

-- Rustに対して有効なフォーマッタをrustfmtに設定
vim.g.neoformat_enabled_rust = { "rustfmt" }
