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

source ~/.zshrc
