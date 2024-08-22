require('CopilotChat').setup {
  debug= true,
}
vim.api.nvim_set_keymap('n', '<leader>ccq', ':lua (function() local input = vim.fn.input("Quick Chat: ") if input ~= "" then require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer }) end end)()<CR>', {noremap = true, silent = true})
