#!/bin/zsh

if [ -d ~/.config/nvim ]; then
  echo "nvchad is already installed"
else
  echo "nvchad not found"
  echo "Installing nvchad..."
  git clone https://github.com/NvChad/starter ~/.config/nvim
  echo "nvchad is ready to go 🎉"
fi