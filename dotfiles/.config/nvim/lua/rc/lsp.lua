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

lspconfig.elmls.setup {
  root_dir = require "lspconfig.util".root_pattern("elm.json",".git")
}

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


lspconfig.kotlin_language_server.setup{
  settings = {
    kotlin = {
      compiler = {
        jvm = {
          target = "1.8";
        }
      };
    };
  }
}
