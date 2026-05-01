local telescope = require('telescope')
local builtin   = require('telescope.builtin')
local actions   = require('telescope.actions')
local keymap    = vim.keymap

local function project_root()
  local path = vim.api.nvim_buf_get_name(0)

  if path == '' then
    return vim.uv.cwd()
  end

  local root = vim.fs.root(path, '.git')
  if root ~= nil then
    return root
  end

  return vim.uv.cwd()
end

local function with_project_root(picker)
  return function(opts)
    opts = vim.tbl_extend('force', { cwd = project_root() }, opts or {})
    return picker(opts)
  end
end

builtin.find_files = with_project_root(builtin.find_files)
builtin.git_files = with_project_root(builtin.git_files)
builtin.live_grep = with_project_root(builtin.live_grep)
builtin.grep_string = with_project_root(builtin.grep_string)

keymap.set('n', '<leader>ff', function()
  local ok = pcall(builtin.git_files, { show_untracked = true })
  if not ok then
    builtin.find_files()
  end
end, { desc = 'telescope: find files (git aware)' })

keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'telescope: live grep (git root)' })
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
