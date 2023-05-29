require('which-key').register({
['<leader>ff'] = {'<Cmd>Telescope git_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', 'telescope: find file'},
})
