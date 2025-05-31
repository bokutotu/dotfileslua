----------------------------------------------------------------
--  nvim-cmp 2025-05 “高速＋自動補完” 最小構成
----------------------------------------------------------------
vim.g.completeopt = "menu,menuone,noselect"

local cmp       = require("cmp")
local luasnip   = require("luasnip")
local lspkind   = require("lspkind")
local types     = require("cmp.types")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  -- ★ 自動補完 ON（デフォルト）だが処理間隔をゆるめる
  completion  = { keyword_length = 1 },
  performance = {
    debounce             = 80,   -- 80 ms 以内の連打はまとめる
    throttle             = 40,   -- ポップアップ再描画間隔
    fetching_timeout     = 200,  -- ソースが 200 ms 越えたら打ち切り
    max_view_entries     = 40,   -- 一度に描画する候補数
  },

  ----------------------------------------------------------------
  -- スニペット
  ----------------------------------------------------------------
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },

  ----------------------------------------------------------------
  -- キーマッピング
  ----------------------------------------------------------------
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"]   = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-p>"]   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-Space>"] = cmp.mapping.complete(),            -- 手動呼び出し
    ["<C-c>"]   = cmp.mapping.abort(),                 -- 閉じる
    ["<CR>"]    = cmp.mapping.confirm({ select = false }),
  }),

  ----------------------------------------------------------------
  -- ソース：軽量常駐＋重いものは async / 3 文字～
  ----------------------------------------------------------------
  sources = cmp.config.sources({
    { name = "nvim_lsp",               priority = 100 },
    { name = "luasnip",                priority =  90 },
    { name = "path",                   priority =  80 },
    { name = "nvim_lsp_signature_help",priority =  80 },
  }, {
    { name = "buffer",  priority = 50,       -- 現在バッファのみ
      option = {
        get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end
      }
    },
    { name = "dictionary", keyword_length = 3, async = true, priority = 30 },
    { name = "spell",      keyword_length = 3, priority = 20 },
  }),

  ----------------------------------------------------------------
  -- 表示フォーマット（元設定をそのまま）
  ----------------------------------------------------------------
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      menu = {
        buffer           = "[Buffer]",
        nvim_lsp         = "[LSP]",
        cmp_tabnine      = "[TabNine]",
        copilot          = "[Copilot]",
        luasnip          = "[LuaSnip]",
        nvim_lua         = "[NeovimLua]",
        latex_symbols    = "[LaTeX]",
        path             = "[Path]",
        omni             = "[Omni]",
        spell            = "[Spell]",
        emoji            = "[Emoji]",
        calc             = "[Calc]",
        rg               = "[Rg]",
        treesitter       = "[TS]",
        dictionary       = "[Dictionary]",
        mocword          = "[mocword]",
        cmdline_history  = "[History]",
      },
    }),
  },

  ----------------------------------------------------------------
  -- 並べ替えロジック（元のカスタム関数を維持）
  ----------------------------------------------------------------
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      function(e1, e2)
        local k1 = e1:get_kind(); k1 = (k1 == types.lsp.CompletionItemKind.Text) and 100 or k1
        local k2 = e2:get_kind(); k2 = (k2 == types.lsp.CompletionItemKind.Text) and 100 or k2
        if k1 ~= k2 then
          if k1 == types.lsp.CompletionItemKind.Snippet then return false end
          if k2 == types.lsp.CompletionItemKind.Snippet then return true  end
          return k1 < k2
        end
      end,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})

----------------------------------------------------------------
-- 追加：Markdown / プレーンテキストでは辞書とスペルを優先
----------------------------------------------------------------
cmp.setup.filetype({ "markdown", "text" }, {
  sources = {
    { name = "dictionary", keyword_length = 2, async = true, priority = 90 },
    { name = "spell",      keyword_length = 2, priority = 80 },
    { name = "buffer",     priority = 60, option = { get_bufnrs = function() return {0} end } },
  },
})

