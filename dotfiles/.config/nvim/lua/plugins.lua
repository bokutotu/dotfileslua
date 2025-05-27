local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

util = require('packer/util')

return require('packer').startup({function()
  -- Packer can manage itself as an optional plugin
  use {'wbthomason/packer.nvim', opt = true}
  use 'github/copilot.vim'

  use 'navarasu/onedark.nvim'

  -- 大切そうなやつ
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'MunifTanjim/nui.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'rcarriga/nvim-notify'
  use 'vim-denops/denops.vim'

  -- キーバインドをいい感じにする
  -- use 'folke/which-key.nvim'

  -- buffer line
  use {'akinsho/bufferline.nvim', tag = "v4.*", requires = 'kyazdani42/nvim-web-devicons'}

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  
  -- fizzy finder
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-frecency.nvim'

  -- lsp
  use 'neovim/nvim-lspconfig'

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
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
  use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'
  use 'lukas-reineke/cmp-under-comparator'
  use 'nvimdev/lspsaga.nvim' 
  use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}

  -- rust
  use 'simrat39/rust-tools.nvim'
  use 'mrcjkb/rustaceanvim'
  use 'rust-lang/rust.vim'

  -- 今いる単語をハイライト
  use 'RRethy/vim-illuminate'

  -- treesitter
  use 'nvim-treesitter/nvim-treesitter'
  use 'yioneko/nvim-yati'
  
  -- 括弧
  use 'andymass/vim-matchup'
  use 'windwp/nvim-autopairs'

  -- snipet
  use 'L3MON4D3/LuaSnip'

  -- コメント
  use 'numToStr/Comment.nvim'

  -- MarkDown
  use 'iamcco/markdown-preview.nvim'

  use {
      "SmiteshP/nvim-navic",
      requires = "neovim/nvim-lspconfig"
  }

  -- インデントをみやすくする
  use { 'lukas-reineke/indent-blankline.nvim', tag = 'v3.8.2' }

  -- コード内ファジーファインダ
  use 'yuki-yano/fuzzy-motion.vim'

  -- file explorer
  use 'nvim-tree/nvim-tree.lua'

  use 'udalov/kotlin-vim'

  use 'sbdchd/neoformat'

  use 'akinsho/flutter-tools.nvim'

  use {
    'CopilotC-Nvim/CopilotChat.nvim',
    requires = {
      'github/copilot.vim',
      'nvim-lua/plenary.nvim',
    },
    branch = 'main',
    opts = {
      debug = true,
    }
  }

  use {
    'yetone/avante.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-lua/popup.nvim',
      "stevearc/dressing.nvim",
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'echasnovski/mini.pick',
      'nvim-telescope/telescope.nvim',
      'hrsh7th/nvim-cmp',
      'ibhagwan/fzf-lua',
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
      {
        'HakonHarnes/img-clip.nvim',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  }

  use {
    'mrcjkb/haskell-tools.nvim',
    branch = 'master',
    requires = { 'nvim-lua/plenary.nvim' },
  }

end, config = {compile_path = util.join_paths(vim.fn.stdpath('config'), 'packer_compiled.vim')}});
