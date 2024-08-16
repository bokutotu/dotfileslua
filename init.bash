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
