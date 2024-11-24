#!/bin/zsh

if mise ls | grep -q node; then
  echo "- 👨🏻‍🚀 Node.js is already installed"
else
  echo "- 👨🏻‍🚀 Node.js not found"
  echo "- 👨🏻‍🚀 Installing Node.js..."
  mise install node@latest
fi