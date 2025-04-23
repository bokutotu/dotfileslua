-- require('which-key').register({
-- ['<leader>ff'] = {'<Cmd>Telescope git_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', 'telescope: find file'},
-- ['<leader>jj'] = {'<Cmd>Telescope buffers<CR>', 'telescope find buffers'}
-- })
-- Function to set keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Telescope keybindings
map('n', '<leader>ff', '', {
  desc = 'telescope: git files (from cwd)',
  callback = function()
    require('telescope.builtin').find_files({
      find_command = { 'git', 'ls-files' },
    })
  end,
})
map('n', '<leader>jj', '<Cmd>Telescope buffers<CR>', { desc = 'telescope find buffers' })


-- Telescope key mappings
local actions = require('telescope.actions')

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
      },
    },
  },
}

