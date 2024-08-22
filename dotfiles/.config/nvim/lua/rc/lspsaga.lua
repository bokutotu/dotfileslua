local lspsaga = require 'lspsaga'
lspsaga.setup { -- defaults ...
  ui = {
    code_action = '',  -- コードアクションアイコンを空に設定
  },
  debug = false,
  use_saga_diagnostic_sign = true,
  -- diagnostic sign
  error_sign = "",
  warn_sign = " ",
  hint_sign = "",
  infor_sign = "",
  diagnostic_header_icon = "   ",
  -- code action title icon
  code_action_icon = "💡",
  code_action_prompt = {
    enable = true,
    sign = true,
    sign_priority = 40,
    virtual_text = true,
  },
  finder_definition_icon = "  ",
  finder_reference_icon = "  ",
  max_preview_lines = 10,
  finder_action_keys = {

    open = "o",
    vsplit = "s",
    split = "i",
    quit = "q",
    scroll_down = "<C-j>",
    scroll_up = "<C-k>",
  },
  code_action_keys = {
    quit = "q",
    exec = "<CR>",
  },
  rename_action_keys = {
    quit = "<C-c>",
    exec = "<CR>",
  },
  definition_preview_icon = "󰇀 ",
  border_style = "single",
  rename_prompt_prefix = "➤",
  rename_output_qflist = {
    enable = false,
    auto_open_qflist = false,
  },
  server_filetype_map = {},
  diagnostic_prefix_format = "%d. ",
  diagnostic_message_format = "%m %c",
  highlight_prefix = false,
}

-- local wk = require("which-key")
-- wk.register({
--   ['gr'] =  {'<Cmd>Lspsaga rename<CR>', 'Lspsaga Rename'},
--   ['gx'] =  {'<Cmd>Lspsaga code_action<CR>', 'Lspsaga Code Action'},
--   ['K'] =   {'<Cmd>Lspsaga hover_doc<CR>', 'Lspsaga hover document'},
--   ['go'] =  {'<Cmd>Lspsaga show_line_diagnostics<CR>', 'Lspsaga show_line_diagnostics'},
--   ['gj'] =  {'<Cmd>Lspsaga diagnostic_jump_next<CR>', 'Lspsaga diagnostic_jump_next'},
--   ['gk'] =  {'<Cmd>Lspsaga diagnostic_jump_prev<CR>', 'Lspsaga diagnostic_jump_next'},
-- })

--- In lsp attach function
local map = vim.api.nvim_buf_set_keymap
--- map(0, "n", "gr", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
--- map(0, "n", "gx", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
--- map(0, "x", "gx", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
--- map(0, "n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
--- map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
--- map(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", {silent = true, noremap = true})
--- map(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", {silent = true, noremap = true})
-- map(0, "n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
-- map(0, "n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
-- Function to set keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Lspsaga keybindings
map('n', 'gr', '<Cmd>Lspsaga rename<CR>', { desc = 'Lspsaga Rename' })
map('n', 'gx', '<Cmd>Lspsaga code_action<CR>', { desc = 'Lspsaga Code Action' })
map('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', { desc = 'Lspsaga hover document' })
map('n', 'go', '<Cmd>Lspsaga show_line_diagnostics<CR>', { desc = 'Lspsaga show_line_diagnostics' })
map('n', 'gj', '<Cmd>Lspsaga diagnostic_jump_next<CR>', { desc = 'Lspsaga diagnostic_jump_next' })
map('n', 'gk', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', { desc = 'Lspsaga diagnostic_jump_prev' })
