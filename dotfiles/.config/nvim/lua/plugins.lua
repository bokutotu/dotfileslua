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

  -- 大切そうなやつ
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'MunifTanjim/nui.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'rcarriga/nvim-notify'
  use 'vim-denops/denops.vim'

  -- キーバインドをいい感じにする
  use 'folke/which-key.nvim'

  -- buffer line
  use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}

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
  use 'williamboman/nvim-lsp-installer'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-nvim-lsp-document-symbol'
  use 'hrsh7th/cmp-nvim-lua'
  use 'saadparwaiz1/cmp_luasnip'
  use 'f3fora/cmp-spell'
  use 'yutkat/cmp-mocword'
  use 'ray-x/cmp-treesitter'
  -- use 'tami5/lspsaga.nvim'
  use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'
  use 'lukas-reineke/cmp-under-comparator'
  use 'kkharji/lspsaga.nvim' 
  use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}

  -- rust
  use 'simrat39/rust-tools.nvim'

  -- treesitter
  use 'nvim-treesitter/nvim-treesitter'
  use 'yioneko/nvim-yati'
  
  -- 括弧
  use 'andymass/vim-matchup'
  use 'jiangmiao/auto-pairs'

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
  use "lukas-reineke/indent-blankline.nvim"

  -- コード内ファジーファインダ
  use 'yuki-yano/fuzzy-motion.vim'

end, config = {compile_path = util.join_paths(vim.fn.stdpath('config'), 'packer_compiled.vim')}});
