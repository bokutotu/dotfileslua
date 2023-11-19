require('which-key').register({
['<leader>ff'] = {'<Cmd>Telescope git_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', 'telescope: find file'},
['<leader>jj'] = {'<Cmd>Telescope buffers<CR>', 'telescope find buffers'}
})

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

