#!/bin/zsh
# This function installs Homebrew Bundle if it is not already installed.
echo "- 👨🏻‍🚀 Install Homebrew Bundle"
echo "- 👨🏻‍🚀 Checking Homebrew Bundle..."

if brew bundle check --file='~/.config/homebrew/Brewfile'; then
  echo "- 👨🏻‍🚀 Homebrew Bundle is already installed"
else
  echo "- 👨🏻‍🚀 Homebrew Bundle not found"
  echo "- 👨🏻‍🚀 Installing Homebrew Bundle..."
  brew bundle install --file='~/.config/homebrew/Brewfile'
  echo "- 👨🏻‍🚀 Homebrew Bundle is ready to go 🎉"
fi
