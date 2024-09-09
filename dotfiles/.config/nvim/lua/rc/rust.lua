local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<leader>rd', '<cmd>RustLsp renderDiagnostic current<CR>', { desc = 'rust: render diagnostic' })

-- Run cargo fmt on save
vim.api.nvim_exec([[
  augroup RustFmt
    autocmd!
    autocmd BufWritePre *.rs :silent! lua vim.lsp.buf.formatting_sync(nil, 100)
  augroup END
]], false)
