#!/bin/zsh

echo "🤖 Node.js"
if type node 1>/dev/null 2>&1 ; then
  echo "- 🤖 Node.js is already installed"
else
  echo "- 🤖 Node.js not found"
  echo "- 🤖 Installing Node.js..."
  mise use -g node@latest
fi

echo "- 🤖 Node.js is ready to go 🎉"

