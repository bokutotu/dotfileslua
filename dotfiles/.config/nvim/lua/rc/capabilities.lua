local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Pre-merge Neovim default capabilities with cmp-nvim-lsp additions so that
-- language servers keep built-in features (code actionsなど) while benefiting
-- from cmp 拡張.
local base = vim.lsp.protocol.make_client_capabilities()
local merged = vim.tbl_deep_extend("force", base, cmp_nvim_lsp.default_capabilities())

local M = {}

function M.get()
  -- Return a fresh copy in case a language server mutates the table.
  return vim.tbl_deep_extend("force", {}, merged)
end

return M
