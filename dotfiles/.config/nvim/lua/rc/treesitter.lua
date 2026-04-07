local ts = require('nvim-treesitter')

local parsers = { 'lua', 'rust', 'python', 'c', 'cpp' }
local filetypes = { 'lua', 'rust', 'python', 'c', 'cpp' }
local group = vim.api.nvim_create_augroup('treesitter_main_setup', { clear = true })

ts.setup({
  install_dir = vim.fn.stdpath('data') .. '/site',
})

ts.install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = filetypes,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
