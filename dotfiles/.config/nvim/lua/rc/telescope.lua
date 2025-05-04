local telescope = require('telescope')
local builtin   = require('telescope.builtin')
local actions   = require('telescope.actions')
local keymap    = vim.keymap

keymap.set('n', '<leader>ff', function()
  local ok = pcall(builtin.git_files, { show_untracked = true })
  if not ok then
    builtin.find_files()
  end
end, { desc = 'telescope: find files (git aware)' })

keymap.set('n', '<leader>jj', builtin.buffers, { desc = 'telescope: buffers' })

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ['<C-n>'] = actions.move_selection_next,
        ['<C-p>'] = actions.move_selection_previous,
      },
      n = { ['q'] = actions.close },
    },
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern  = 'TelescopePrompt',
  callback = function() vim.b.autopairs_enabled = false end,
})
