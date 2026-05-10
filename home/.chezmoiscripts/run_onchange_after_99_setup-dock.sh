#!/bin/zsh
set -euo pipefail

# Dock の persistent-apps と Dock 全体の defaults を宣言的に管理する。
# このスクリプトのハッシュが変わったときだけ再実行される（run_onchange_*）。

if ! command -v dockutil >/dev/null 2>&1; then
  echo "dockutil not found. Brewfile に brew \"dockutil\" を追加して brew bundle してください。" >&2
  exit 1
fi

# Dock 全体の挙動
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string bottom

# persistent-apps を宣言的に再構築（手で並び替えていても巻き戻る）
dockutil --remove all --no-restart

dockutil --add "/System/Applications/Launchpad.app"   --no-restart
dockutil --add "/System/Applications/Mail.app"        --no-restart
dockutil --add "/Applications/Brave Browser.app"      --no-restart
dockutil --add "/Applications/WezTerm.app"            --no-restart
dockutil --add "/Applications/Visual Studio Code.app" --no-restart
dockutil --add "/Applications/ChatGPT.app"            --no-restart
dockutil --add "/Applications/Docker.app"             --no-restart
dockutil --add "/Applications/1Password.app"          --no-restart
dockutil --add "/Applications/Obsidian.app"           --no-restart

killall Dock
