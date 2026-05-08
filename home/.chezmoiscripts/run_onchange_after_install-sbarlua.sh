#!/bin/zsh

echo "🌙 SbarLua"
SBARLUA_LIB="$HOME/.local/share/sketchybar_lua/sketchybar.so"
if [ -f "$SBARLUA_LIB" ]; then
  echo "- 🌙 SbarLua is already installed"
  exit 0
fi

if ! type lua 1>/dev/null 2>&1; then
  echo "- 🌙 lua not found, skipping (mise でインストールされている前提)"
  exit 0
fi

echo "- 🌙 Installing SbarLua..."
TMPDIR=$(mktemp -d)
git clone --depth=1 https://github.com/FelixKratz/SbarLua.git "$TMPDIR/SbarLua" || {
  echo "- 🌙 git clone failed"
  rm -rf "$TMPDIR"
  exit 1
}
(cd "$TMPDIR/SbarLua" && make install) || {
  echo "- 🌙 make install failed"
  rm -rf "$TMPDIR"
  exit 1
}
rm -rf "$TMPDIR"

echo "- 🌙 SbarLua is ready to go 🎉"
