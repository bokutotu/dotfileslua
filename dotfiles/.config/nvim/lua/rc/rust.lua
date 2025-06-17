-- Rust keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    vim.keymap.set(
      "n",
      "<leader>rd",
      "<cmd>RustLsp renderDiagnostic current<CR>",
      { desc = "rust: render diagnostic", buffer = ev.buf }
    )
  end,
})

-- Setup rustaceanvim
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()
local util = require("lspconfig.util")

vim.g.rustaceanvim = {
  tools = {
    enable_clippy = true,
    hover_actions = {
      auto_focus = true,
    },
    executor = require("rustaceanvim/executors").termopen,
    reload_workspace_from_cargo_toml = true,
  },
  server = {
    cmd = { "rust-analyzer" },
    standalone = false,  -- Don't use standalone mode
    capabilities = capabilities,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
          extraArgs = { "--", "-W", "clippy::pedantic" },
        },
        cargo = {
          allFeatures = true,
        },
      },
    },
    root_dir = function(fname)
      local function is_library(path)
        local cargo_home = os.getenv("CARGO_HOME") or util.path.join(vim.env.HOME, ".cargo")
        local registry = util.path.join(cargo_home, "registry", "src")
        local git_registry = util.path.join(cargo_home, "git", "checkouts")
        local rustup_home = os.getenv("RUSTUP_HOME") or util.path.join(vim.env.HOME, ".rustup")
        local toolchains = util.path.join(rustup_home, "toolchains")

        for _, item in ipairs({ toolchains, registry, git_registry }) do
          if util.path.is_descendant(item, path) then
            return true
          end
        end
        return false
      end

      if is_library(fname) then
        return nil
      end

      return util.root_pattern("Cargo.toml", "rust-project.json")(fname)
        or util.find_git_ancestor(fname)
    end,
  },
}

