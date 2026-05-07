#!/bin/zsh

# Apple SF Pro / SF Mono / SF Symbols を sudo 回避で per-user 領域にインストール
# ─ brew cask は .pkg を /Library/Fonts/ にインストールしようとして sudo を要求するので、
#   DMG → .pkg → pkgutil --expand-full で .otf を取り出し、~/Library/Fonts/ へコピーする

echo "🍎 Apple SF Fonts"

FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

is_installed() {
  /bin/ls "$FONT_DIR" 2>/dev/null | grep -qi "$1"
}

install_dmg_pkg_fonts() {
  local cask_name="$1"
  local marker="$2"
  if is_installed "$marker"; then
    echo "- 🍎 $cask_name is already installed"
    return 0
  fi
  echo "- 🍎 Installing $cask_name..."
  brew fetch --cask "$cask_name" >/dev/null 2>&1 || {
    echo "- 🍎 brew fetch failed for $cask_name"
    return 1
  }
  local dmg
  dmg=$(brew --cache --cask "$cask_name" 2>/dev/null)
  if [ ! -f "$dmg" ]; then
    echo "- 🍎 dmg not found for $cask_name"
    return 1
  fi
  local mp
  mp=$(hdiutil attach -nobrowse "$dmg" 2>/dev/null | awk '/\/Volumes\// {print $NF}' | head -1)
  if [ -z "$mp" ]; then
    echo "- 🍎 mount failed for $cask_name"
    return 1
  fi
  local pkg
  pkg=$(find "$mp" -maxdepth 2 -name "*.pkg" 2>/dev/null | head -1)
  if [ -z "$pkg" ]; then
    echo "- 🍎 no .pkg in dmg for $cask_name"
    hdiutil detach -quiet "$mp"
    return 1
  fi
  local tmp
  tmp=$(mktemp -d)
  pkgutil --expand-full "$pkg" "$tmp/x" >/dev/null 2>&1
  local count=0
  while IFS= read -r f; do
    if cp -n "$f" "$FONT_DIR/" 2>/dev/null; then
      count=$((count + 1))
    fi
  done < <(find "$tmp/x" -type f \( -iname "*.otf" -o -iname "*.ttf" \) 2>/dev/null)
  rm -rf "$tmp"
  hdiutil detach -quiet "$mp"
  echo "- 🍎 $cask_name: copied $count font files"
}

install_dmg_pkg_fonts font-sf-pro "SF-Pro"
install_dmg_pkg_fonts font-sf-mono "SF-Mono"
install_dmg_pkg_fonts sf-symbols "SF-Pro-Symbols"

echo "- 🍎 Apple SF Fonts are ready to go 🎉"
