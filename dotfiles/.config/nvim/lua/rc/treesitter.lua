-- Tree-sitterの設定
require'nvim-treesitter.configs'.setup {
  -- ここで有効にする機能を指定します
  ensure_installed = {"lua","rust", "python", "dart", "c", "cpp"}, -- インストールする言語パーサを指定
  sync_install = false, -- 起動時にインストールを同期的に実行するかどうか
  auto_install = true, -- 言語パーサがない場合に自動的にインストールするかどうか
  highlight = {
    enable = true, -- ハイライトを有効にする
    additional_vim_regex_highlighting = false, -- Vimの正規表現ハイライトを追加で使用するかどうか
  },
  indent = {
    enable = true, -- インデントをTree-sitterで行うかどうか
  },
}

