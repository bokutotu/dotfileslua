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
    end, { buffer = true })
  end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function organize_imports_and_format(bufnr)
  local p = vim.lsp.util.make_range_params(nil, vim.lsp.get_clients()[1].offset_encoding)
  p.context = { only = { "source.organizeImports" } }
  local r = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", p, 1500)
  if r then
    for _, v in pairs(r) do
      for _, a in ipairs(v.result or {}) do
        if a.edit then vim.lsp.util.apply_workspace_edit(a.edit, "utf-8") end
        if a.command then vim.lsp.buf.execute_command(a.command) end
      end
    end
  end
  vim.lsp.buf.format { bufnr = bufnr, async = false, timeout_ms = 3000, filter = function(c) return c.name == "hls" end }
end

local function on_attach(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    api.nvim_create_autocmd("BufWritePre", {
      group  = api.nvim_create_augroup("HLSFormatOnSave", { clear = false }),
      buffer = bufnr,
      callback = function() organize_imports_and_format(bufnr) end,
    })
  end
  api.nvim_create_autocmd("BufWritePost", {
    group  = api.nvim_create_augroup("HLSDiagnosticsOnSave", { clear = false }),
    buffer = bufnr,
    callback = function()
      vim.diagnostic.reset(nil, bufnr)
      vim.diagnostic.show(nil, bufnr)
    end,
  })
end

vim.o.tags = "./.tags;,./**/*.tags"

local function ensure_tags()
  if vim.fn.filereadable(".tags") == 0 then
    vim.fn.jobwait {
      vim.fn.jobstart({ "fast-tags", "-o", ".tags", "-R", "." }, { stderr_buffered = true }),
    }
  end
end

local function goto_def()
  local enc = vim.lsp.get_clients()[1] and vim.lsp.get_clients()[1].offset_encoding or "utf-8"
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
  ensure_tags()
  vim.cmd("silent! tag " .. vim.fn.expand("<cword>"))
end

map("n", "<F12>",   goto_def)
map("n", "<S-F12>", "<C-t>")

vim.g.haskell_tools = {
  hls = {
    on_attach    = on_attach,
    capabilities = capabilities,
    root_dir = require("lspconfig.util").root_pattern("hie.yaml", "*.cabal", "stack.yaml", ".git"),
    settings = {
      haskell = {
        diagnosticsOnChange = false,
        checkParents        = "CheckOnSave",
        plugin = {
          hlint    = { globalOn = true },
          fourmolu = { globalOn = true },
        },
      },
    },
  },
  tools = {
    generate_tags = true,
    codeLens      = { autoRefresh = false },
    tags = {
      executable         = "fast-tags",
      options            = { "-i", "-o", ".tags", "-R", "." },
      include_extensions = { "hs", "lhs" },
      notify_on_error    = true,
    },
  },
}

