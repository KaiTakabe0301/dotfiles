#!/bin/zsh

if mise ls | grep -q python; then
  echo "- 🐍 Python is already installed"
else
  echo "- 🐍 Python not found"
  echo "- 🐍 Installing Python..."
  mise install python@latest
fi