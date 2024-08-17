#!bin/bash

# update upgrae
apt update && apt upgrade -y

# install zsh
apt install zsh -y

chsh -s $(which zsh)

# Rustのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# ~/.alias.zshにCargoのパスを追加
echo '' >> ~/.alias.zsh
echo '# Rust/Cargo環境変数' >> ~/.alias.zsh
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.alias.zsh

source $HOME/.cargo/env

cargo run --release

cargo install lsd

source ~/.zshrc

  git config --global user.email "mushin.hudoushin@gmail.com"
  git config --global user.name "bokutotu"

# git clone neovim
apt install cmake -y
apt install build-essential -y
apt install gettext -y
git clone https://github.com/neovim/neovim
cd neovim && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

# inistall tmux 
apt install tmux -y

# install deno
 apt install unzip -y
# denoをインストールする
curl -fsSL https://deno.land/x/install/install.sh | sh

echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.alias.zsh
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.alias.zsh

# NVMのインストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# NVMの設定を.alias.zshに追加
echo '' >> ~/.alias.zsh
echo '# NVM設定' >> ~/.alias.zsh
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.alias.zsh
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.alias.zsh
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.alias.zsh

# NVMをソースして即座に使用可能にする
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 最新のNode.js LTSバージョンをインストール
nvm install --lts

# インストールしたLTSバージョンをデフォルトに設定
nvm use --lts

# Node.jsとnpmのバージョンを表示して確認
node --version
npm --version

