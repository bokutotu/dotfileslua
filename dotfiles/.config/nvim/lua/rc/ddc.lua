local fn = vim.fn

vim.o.completeopt = 'menu,menuone,noselect'

local function t(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function pum_visible()
  return fn['pum#visible']() == 1
end

vim.keymap.set('i', '<C-n>', function()
  if pum_visible() then
    return t('<Cmd>call pum#map#select_relative(1)<CR>')
  end
  return t('<C-n>')
end, { expr = true, replace_keycodes = false })

vim.keymap.set('i', '<C-p>', function()
  if pum_visible() then
    return t('<Cmd>call pum#map#select_relative(-1)<CR>')
  end
  return t('<C-p>')
end, { expr = true, replace_keycodes = false })

vim.keymap.set('i', '<CR>', function()
  if pum_visible() then
    return t('<Cmd>call pum#map#confirm()<CR>')
  end
  return t('<CR>')
end, { expr = true, replace_keycodes = false })

vim.keymap.set('i', '<C-c>', function()
  if pum_visible() then
    return t('<Cmd>call pum#map#cancel()<CR>')
  end
  return t('<C-c>')
end, { expr = true, replace_keycodes = false })

vim.api.nvim_create_autocmd('User', {
  pattern = 'DenopsReady',
  once = true,
  callback = function()
    local snippet_cb = fn['denops#callback#register'](function(body)
      if vim.snippet and vim.snippet.expand then
        vim.snippet.expand(body)
      else
        vim.api.nvim_put(vim.split(body, '\n'), 'c', true, true)
      end
    end)

    fn['ddc#custom#patch_global']({
      ui = 'pum',
      autoCompleteEvents = { 'InsertEnter', 'TextChangedI', 'TextChangedP' },
      sources = { 'lsp' },
      sourceOptions = {
        _ = {
          matchers = { 'matcher_head' },
          sorters = { 'sorter_rank' },
        },
        lsp = {
          mark = 'LSP',
          forceCompletionPattern = [[\.\w*|\w*::]],
        },
      },
      sourceParams = {
        lsp = {
          enableResolveItem = true,
          enableAdditionalTextEdit = true,
          snippetEngine = snippet_cb,
        },
      },
    })

    fn['ddc#enable']()
  end,
})
