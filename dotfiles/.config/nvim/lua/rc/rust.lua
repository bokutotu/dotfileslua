-- let g:rustfmt_autosave = 1 in lua
vim.g.rustfmt_autosave = 1

require('rust-tools').setup({
  -- ここに他のrust-toolsの設定を記述
  tools = {
    inlay_hints = {
      -- inlay hintsの設定
      auto = true, -- 自動でinlay hintsを表示する
      -- その他の設定...
    },
  },
})

-- または、inlay hintsを手動で有効化
-- local rust_tools_inlay_hints = require('path_to_your_module') -- このモジュールのパスを適宜置き換えてください
-- rust_tools_inlay_hints.enable()

