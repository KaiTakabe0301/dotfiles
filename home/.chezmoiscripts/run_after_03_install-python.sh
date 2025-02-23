#!/bin/zsh

echo '🐍 Python'
if type python 1>/dev/null 2>&1 ; then
  echo "- 🐍 Python is already installed"
else
  echo "- 🐍 Python not found"
  echo "- 🐍 Installing Python..."
  mise use -g python@latest
fi

echo "- 🐍 Python is ready to go 🎉"

