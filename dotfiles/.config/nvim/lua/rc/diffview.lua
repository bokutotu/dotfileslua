require('diffview').setup({
  view = {
    default = {
      layout = 'diff2_horizontal',
    },
    file_history = {
      layout = 'diff2_horizontal',
    },
  },
  hooks = {
    diff_buf_read = function(_)
      -- Keep unchanged sections expanded by default (VSCode-like full-file diff).
      vim.opt_local.foldlevel = 99
      vim.opt_local.foldenable = true
    end,
  },
})
