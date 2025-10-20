-- ─────────────────────────────────────────────────────────────
--  Packer bootstrap
-- ─────────────────────────────────────────────────────────────
local fn    = vim.fn
local path  = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(path)) > 0 then
  fn.system({ 'git', 'clone', '--depth', '1',
              'https://github.com/wbthomason/packer.nvim', path })
  vim.cmd 'packadd packer.nvim'
end

local packer = require('packer')
local util   = require('packer.util')

-- ─────────────────────────────────────────────────────────────
--  Plugins
-- ─────────────────────────────────────────────────────────────
return packer.startup({
  function(use)   -- ← ★ use 引数必須

    ------------------------------------------------------------------
    -- Packer 本体 & テーマ
    ------------------------------------------------------------------
    use 'wbthomason/packer.nvim'
    use 'navarasu/onedark.nvim'
    use 'github/copilot.vim'

    ------------------------------------------------------------------
    -- 共通依存
    ------------------------------------------------------------------
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'MunifTanjim/nui.nvim'
    use 'kyazdani42/nvim-web-devicons'
    use 'rcarriga/nvim-notify'
    use 'vim-denops/denops.vim'

    ------------------------------------------------------------------
    -- UI
    ------------------------------------------------------------------
    use { 'akinsho/bufferline.nvim', tag = 'v4.*', requires = 'kyazdani42/nvim-web-devicons' }
    use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }

    ------------------------------------------------------------------
    -- Telescope
    ------------------------------------------------------------------
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.6' }
    use 'nvim-telescope/telescope-frecency.nvim'

    ------------------------------------------------------------------
    -- LSP & cmp
    ------------------------------------------------------------------
    use 'neovim/nvim-lspconfig'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-emoji'
    use 'onsails/lspkind-nvim'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-nvim-lsp-document-symbol'
    use 'hrsh7th/cmp-nvim-lua'
    use 'saadparwaiz1/cmp_luasnip'
    use 'f3fora/cmp-spell'
    use 'yutkat/cmp-mocword'
    use 'ray-x/cmp-treesitter'
    use 'lukas-reineke/cmp-under-comparator'
    use { 'tzachar/cmp-tabnine', run = './install.sh', requires = 'hrsh7th/nvim-cmp' }

    use 'folke/lsp-colors.nvim'
    use 'folke/trouble.nvim'
    use { 'nvimdev/lspsaga.nvim', branch = 'main' }

    ------------------------------------------------------------------
    -- Rust
    ------------------------------------------------------------------
    use 'simrat39/rust-tools.nvim'
    use 'mrcjkb/rustaceanvim'
    use 'rust-lang/rust.vim'

    ------------------------------------------------------------------
    -- 補助プラグイン
    ------------------------------------------------------------------
    use 'RRethy/vim-illuminate'

    -- Treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'yioneko/nvim-yati'

    -- 括弧 / autopairs
    -- use 'andymass/vim-matchup'
    use 'windwp/nvim-autopairs'

    -- Snippet
    use 'L3MON4D3/LuaSnip'

    -- コメント
    use 'numToStr/Comment.nvim'

    -- Markdown
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', ft = { 'markdown' } }

    -- Breadcrumbs
    use { 'SmiteshP/nvim-navic', requires = 'neovim/nvim-lspconfig' }

    -- Indent guides
    use { 'lukas-reineke/indent-blankline.nvim', tag = 'v3.8.2' }

    -- Fuzzy motion
    use 'yuki-yano/fuzzy-motion.vim'

    -- File explorer
    use 'nvim-tree/nvim-tree.lua'

    -- Git
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

    -- Kotlin
    use 'udalov/kotlin-vim'

    -- Formatter
    use 'sbdchd/neoformat'

    -- Flutter
    use 'akinsho/flutter-tools.nvim'

    -- Haskell
    use { 'mrcjkb/haskell-tools.nvim', branch = 'master'}

    ------------------------------------------------------------------
    -- 自動同期 (初回 bootstrap されたとき)
    ------------------------------------------------------------------
    if packer_bootstrap then
      require('packer').sync()
    end
  end,

  --------------------------------------------------------------------
  -- Packer 設定
  --------------------------------------------------------------------
  config = {
    compile_path = util.join_paths(vim.fn.stdpath('config'), 'lua', 'packer_compiled.lua'),
    git = { clone_timeout = 300 },
    display = { open_fn = function()
      return require('packer.util').float({ border = 'rounded' })
    end },
  }
})

