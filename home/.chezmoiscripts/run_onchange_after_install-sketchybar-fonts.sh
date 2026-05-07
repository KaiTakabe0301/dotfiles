#!/bin/zsh

echo "🌙 sketchybar-app-font-bg"
FONT_DIR="$HOME/Library/Fonts"
FONT_FILE="$FONT_DIR/sketchybar-app-font.ttf"
ICON_MAP_DIR="$HOME/.config/sketchybar"
ICON_MAP_FILE="$ICON_MAP_DIR/icon_map.sh"

mkdir -p "$FONT_DIR" "$ICON_MAP_DIR"

if [ -f "$FONT_FILE" ]; then
  echo "- 🌙 sketchybar-app-font.ttf is already installed"
else
  echo "- 🌙 Downloading sketchybar-app-font.ttf..."
  curl -fsSL "https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf" \
    -o "$FONT_FILE" || {
    echo "- 🌙 download failed"
    exit 1
  }
fi

if [ -f "$ICON_MAP_FILE" ]; then
  echo "- 🌙 icon_map.sh is already installed"
else
  echo "- 🌙 Downloading icon_map.sh..."
  curl -fsSL "https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/icon_map.sh" \
    -o "$ICON_MAP_FILE" || {
    echo "- 🌙 download failed"
    exit 1
  }
  chmod +x "$ICON_MAP_FILE"
fi

echo "- 🌙 sketchybar fonts are ready to go 🎉"
