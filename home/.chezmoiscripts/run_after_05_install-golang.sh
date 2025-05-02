#!/bin/zsh

echo '🏎💨 golang'
if type go 1>/dev/null 2>&1 ; then
  echo "- 🏎💨 golang is already installed"
else
  echo "- 🏎💨 golang not found"
  echo "- 🏎💨 Installing golang..."
  mise use -g golang@latest
fi

echo "- 🏎💨 golang is ready to go 🎉"

