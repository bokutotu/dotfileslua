require("nvim-lsp-installer").setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})


local lsp_installer = require "nvim-lsp-installer"
local lspconfig = require "lspconfig"
lsp_installer.setup()
for _, server in ipairs(lsp_installer.get_installed_servers()) do
  lspconfig[server.name].setup {
    on_attach = on_attach,
  }
end

lspconfig.ccls.setup {
  init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  },
  filetypes = { "cuda", "cpp", "c" }
}

local ts_ls_path = vim.fn.system("which typescript-language-server"):gsub("%s+", "") -- Trim whitespace

-- Adding configuration for ts_ls
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  settings = {
    -- Add any specific settings here, if needed, for ts_ls
  },
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }, -- Adjust as needed for your needs
  cmd = { ts_ls_path, "--stdio" } -- Use the dynamically determined path
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

  end,
})
