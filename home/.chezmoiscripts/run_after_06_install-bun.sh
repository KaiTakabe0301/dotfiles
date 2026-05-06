#!/bin/zsh

echo "🍞 bun"
if type bun 1>/dev/null 2>&1 ; then
  echo "- 🍞 bun is already installed"
else
  echo "- 🍞 bun not found"
  echo "- 🍞 Installing bun..."
  mise use -g bun@latest
fi

echo "- 🍞 bun is ready to go 🎉"

