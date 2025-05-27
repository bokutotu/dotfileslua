local api = vim.api

local function map(mode, lhs, rhs, opts)
  local o = { noremap = true, silent = true }
  if opts then o = vim.tbl_extend("force", o, opts) end
  vim.keymap.set(mode, lhs, rhs, o)
end

api.nvim_create_autocmd("FileType", {
  pattern = { "haskell", "lhaskell" },
  callback = function()
    map("n", "<leader>rd", function()
      vim.diagnostic.open_float({ scope = "line", border = "rounded" })
    end, { buffer = true, desc = "haskell: render diagnostic" })
  end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach     = function(_, _) end

vim.g.haskell_tools = {
  hls = {
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir     = require("lspconfig.util").root_pattern(
      "*.cabal",
      "stack.yaml",
      "hie.yaml",
      ".ghci",
      "package.yaml"
    ),
    settings = {
      haskell = { checkParents = "CheckOnSave" },
    },
  },
  tools = {
    codeLens = { autoRefresh = true },
  },
}

api.nvim_create_autocmd("LspAttach", {
  group = api.nvim_create_augroup("HaskellSaveActions", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    local bufnr = ev.buf
    local ft    = vim.bo[bufnr].filetype

    if (ft == "haskell" or ft == "lhaskell")
       and client.server_capabilities.inlayHintProvider
       and vim.lsp.inlay_hint.enable      -- API が存在するか確認
    then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client and client.server_capabilities.documentFormattingProvider then
      api.nvim_create_autocmd("BufWritePre", {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end

    api.nvim_create_autocmd("BufWritePost", {
      buffer = ev.buf,
      callback = function()
        vim.defer_fn(function()
          vim.diagnostic.reset(nil, ev.buf)
          vim.diagnostic.show(nil, ev.buf)
        end, 100)
      end,
    })
  end,
})

