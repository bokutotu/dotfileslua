require('which-key').register({
['<leader>ff'] = {'<Cmd>Telescope git_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', 'telescope: find file'},
['<leader>fg'] = {'<Cmd>Telescope live_grep find_command=rg, --ignore --hidden --files prompt_prefix=🔍<CR>', 'telescope: live_grep Search for a string in your current working directory and get results live as you type (respecting .gitignore)'}
})
