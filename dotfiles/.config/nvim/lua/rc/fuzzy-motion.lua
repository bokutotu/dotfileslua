-- local wk = require("which-key")
-- wk.register({
--   ["<Leader><Leader>"] = {"<Cmd>FuzzyMotion<CR>", "Fuzzy Motion"}
-- })

-- Function to set keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<Leader><Leader>', '<Cmd>FuzzyMotion<CR>', { noremap = true, silent = true })
