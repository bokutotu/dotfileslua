vim.g.completeopt = "menu,menuone,noselect"

local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip/loaders/from_vscode").lazy_load()

local types = require("cmp.types")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-j>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-k>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { "i" }),
    ["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
      end, { "i" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Down>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Up>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-c>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 100 },
    { name = "cmp_tabnine", priority = 30 },
    { name = "luasnip", priority = 20 }, -- For luasnip users.
    { name = "path", priority = 100 },
    { name = "nvim_lua", priority = 50 },
    { name = "nvim_lsp_signature_help", priority = 80 },
    { name = "buffer", priority = 50 },
    { name = "omni", priority = 40 },
    { name = "spell", priority = 40 },
    { name = "calc", priority = 50 },
    { name = "treesitter", priority = 30 },
    { name = "dictionary", keyword_length = 2, priority = 10 },
    { name = "mocword", priority = 60 },
    { name = "cmdline_history", priority = 20 },
  }),
  formatting = {
    format = require("lspkind").cmp_format({
      with_text = true,
      menu = {
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        cmp_tabnine = "[TabNine]",
        copilot = "[Copilot]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[NeovimLua]",
        latex_symbols = "[LaTeX]",
        path = "[Path]",
        omni = "[Omni]",
        spell = "[Spell]",
        emoji = "[Emoji]",
        calc = "[Calc]",
        rg = "[Rg]",
        treesitter = "[TS]",
        dictionary = "[Dictionary]",
        mocword = "[mocword]",
        cmdline_history = "[History]",
      },
    }),
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      function(entry1, entry2)
        local kind1 = entry1:get_kind()
        kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
        local kind2 = entry2:get_kind()
        kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
        if kind1 ~= kind2 then
          if kind1 == types.lsp.CompletionItemKind.Snippet then
            return false
          end
          if kind2 == types.lsp.CompletionItemKind.Snippet then
            return true
          end
          local diff = kind1 - kind2
          if diff < 0 then
            return true
          elseif diff > 0 then
            return false
          end
        end
      end,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})

local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- LSPサーバーの共通設定
local on_attach = function(client, bufnr)
  -- ここにLSP接続時のカスタム設定を追加...
end

-- nvim-cmpとLSPの連携
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Rust (rust_analyzer)
require'lspconfig'.rust_analyzer.setup{
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy";
      };
    }
  }
}

-- Python (pyright)
lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- -- Dart (dartls)
-- lspconfig.dartls.setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })
