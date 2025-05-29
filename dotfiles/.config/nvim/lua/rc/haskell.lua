local api = vim.api

local function map(m, lhs, rhs, opt)
  local o = { noremap = true, silent = true }
  if opt then o = vim.tbl_extend("force", o, opt) end
  vim.keymap.set(m, lhs, rhs, o)
end

api.nvim_create_autocmd("FileType", {
  pattern  = { "haskell", "lhaskell" },
  callback = function()
    map("n", "<leader>rd",
      function() vim.diagnostic.open_float({ scope = "line", border = "rounded" }) end,
      { buffer = true })
  end,
})

local function format_with_fourmolu(bufnr)
  vim.lsp.buf.format {
    bufnr      = bufnr,
    async      = false,
    timeout_ms = 8000,
    filter     = function(client) return client.name == "hls" end,
  }
end

local function format_with_stylish(bufnr)
  if vim.fn.executable("stylish-haskell") == 1 then
    local view = vim.fn.winsaveview()
    vim.cmd("keepjumps silent %!stylish-haskell")
    vim.fn.winrestview(view)
  end
end

local function format_haskell(bufnr)
  format_with_fourmolu(bufnr)
  format_with_stylish(bufnr)
end

local function goto_def()
  local enc = (vim.lsp.get_clients()[1] or {}).offset_encoding or "utf-8"
  local p   = vim.lsp.util.make_position_params(nil, enc)
  local r   = vim.lsp.buf_request_sync(0, "textDocument/definition", p, 400)
  if r then
    for _, v in pairs(r) do
      if v.result and not vim.tbl_isempty(v.result) then
        vim.lsp.util.jump_to_location(v.result[1], enc)
        return
      end
    end
  end
  vim.cmd("silent! tag " .. vim.fn.expand("<cword>"))
end

map("n", "<F12>",   goto_def)
map("n", "<S-F12>", "<C-t>")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(client, bufnr)
  api.nvim_create_autocmd("BufWritePre", {
    group   = api.nvim_create_augroup("HLSFmt", { clear = true }),
    buffer  = bufnr,
    callback = function() format_haskell(bufnr) end,
  })
end

vim.o.tags = "./.tags;,./**/*.tags"

vim.g.haskell_tools = {
  hls = {
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir     = require("lspconfig.util").root_pattern("hie.yaml", "*.cabal", "stack.yaml", ".git"),
    settings = {
      haskell = {
        diagnosticsOnChange = false,
        checkParents        = "CheckOnSave",

        formattingProvider  = "fourmolu",

        plugin = {
          ["stylish-haskell"] = { globalOn = true },
          fourmolu            = { globalOn = true },
          ormolu              = { globalOn = false },
          hlint               = { globalOn = true },
        },
      },
    },
  },
  tools = {
    generate_tags = true,
    codeLens      = { autoRefresh = false },
  },
}

