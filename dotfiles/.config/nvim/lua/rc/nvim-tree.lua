-- Disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 50,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- Toggle NvimTree with Ctrl-b
vim.api.nvim_set_keymap("n", "<C-b>", "<cmd>NvimTreeToggle<cr>", { silent = true, noremap = true })

-- Disable nvim-tree-api.node.run.system() when 's' is pressed
vim.api.nvim_set_keymap("n", "s", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ss", "<cmd>lua require'nvim-tree'.on_keypress('ss')<cr>", { noremap = true, silent = true })
