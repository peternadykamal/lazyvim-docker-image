#!/bin/sh

apk add --no-cache \
  wget git bash \
  build-base procps cmake make gcc g++ file \
  curl unzip zsh ripgrep tmux fzf bat nodejs \
  npm python3 py3-pip ncdu neofetch fd zoxide \
  ranger eza neovim lazygit alpine-sdk\
  util-linux coreutils

git clone https://github.com/LazyVim/starter /home/$UNAME/.config/nvim

git clone https://github.com/tmux-plugins/tpm /home/$UNAME/.tmux/plugins/tpm 

source /etc/profile && node --version && npm --version
npm install -g tldr