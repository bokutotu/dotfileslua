vim.g.rustaceanvim = {
  tools = {
    -- Automatically run clippy checks on save
    enable_clippy = true,
    -- Enable hover actions
    hover_actions = {
      auto_focus = true,
    },
  },
  -- Explain error
  server = {
    -- on_attach = function(client, bufnr)
    --   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rd', '<cmd>RustLsp renderDiagnostic<CR>', opts)
    -- end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
          extraArgs = { "--", "-W", "clippy::pedantic" },
        },
      },
    },
  },
}

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<leader>rd', '<cmd>RustLsp renderDiagnostic current<CR>', { desc = 'rust: render diagnostic' })
