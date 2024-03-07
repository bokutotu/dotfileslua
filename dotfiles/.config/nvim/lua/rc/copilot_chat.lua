require('CopilotChat').setup {
  debug= true,
}
vim.api.nvim_set_keymap('n', '<leader>qqq', ':lua require("CopilotChat").ask(vim.fn.input("Quick Chat: "), { selection = require("CopilotChat.select").buffer })<CR>', {noremap = true, silent = true})
