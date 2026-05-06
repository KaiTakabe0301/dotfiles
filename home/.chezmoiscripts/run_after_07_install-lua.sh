#!/bin/zsh

echo "🌙 Lua"
if type lua 1>/dev/null 2>&1 ; then
  echo "- 🌙 Lua is already installed"
else
  echo "- 🌙 Lua not found"
  echo "- 🌙 Installing Lua..."
  mise use -g lua@latest
fi

echo "- 🌙 Lua is ready to go 🎉"
