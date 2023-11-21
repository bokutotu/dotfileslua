-- Disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"
  -- default mappings
  api.config.mappings.default_on_attach(bufnr)
  -- custom mappings
  vim.keymap.del("n", "s", {buffer = bufnr})
end

-- OR setup with some options
require("nvim-tree").setup({
  on_attach = my_on_attach,
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

vim.api.nvim_set_keymap("n", "ss", "<cmd>lua require'nvim-tree'.on_keypress('ss')<cr>", { noremap = true, silent = true })
