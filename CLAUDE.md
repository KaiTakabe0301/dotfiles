# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリの目的

macOS 用 dotfiles を [chezmoi](https://www.chezmoi.io/) で管理する個人リポジトリ。
`./install.sh` を新規 Mac で叩くことで、Xcode CLT → Homebrew → Brewfile → `chezmoi init --apply KaiTakabe0301` までを一気通貫で実行する。

## 最重要: chezmoi コマンドの直接実行は禁止

`home/` 配下を編集した後の反映は **必ず** `chezmoi-apply` スキル経由で行う。`Bash` ツールから `chezmoi diff` / `chezmoi apply` を直接呼ばないこと。

```bash
# 状態確認
.claude/skills/chezmoi-apply/scripts/status.sh

# 差分（パス省略時は全体、指定時はそのパスのみ）
.claude/skills/chezmoi-apply/scripts/diff.sh ~/.config/nvim/

# 反映（必ずターゲットパスを明示。引数なしは不可）
.claude/skills/chezmoi-apply/scripts/apply.sh ~/.config/nvim/ ~/.zshrc
```

理由: `chezmoi` 系コマンドには `--include=files` や `--pager ""` のような `=` やクォートを含むフラグが必要で、Bash ツール経由で直接実行すると権限確認プロンプトが頻発する。スクリプト内でフラグを処理することで回避している。スキルスクリプトは **相対パス** で呼び出すこと（`.claude/settings.json` の許可パターンが相対パスで定義されているため、絶対パスだとマッチせず権限確認が出る）。

詳細は `.claude/skills/chezmoi-apply/SKILL.md` 参照。

## chezmoi ソースの配置と命名規則

- `.chezmoiroot` がリポジトリ直下にあり、内容は `home`。chezmoi のソースディレクトリは **`home/`** に固定されている（リポジトリルートではない）。
- chezmoi 命名規則（`home/` 配下）:
  - `dot_X` → `~/.X`（例: `dot_config` → `~/.config`、`dot_zprezto` → `~/.zprezto`）
  - `private_X` → ファイル/ディレクトリのパーミッションを制限
  - `executable_X` → 実行ビット付与
  - `*.tmpl` → chezmoi の Go テンプレートとして処理（`{{ .chezmoi.* }}` 等が使える）
- `home/.chezmoiignore` はホスト固有の除外（テンプレート可）。`install.sh` 自体は除外対象。
- `home/.chezmoiexternal.toml` は外部リソース取得設定。
- `home/.chezmoiscripts/` の `run_after_NN_*.sh` は **数値プレフィックス順** に実行されるブートストラップ群。順序: `01 brew-bundle → 02 node → 03 python → 04 obsidian-vimrc(tmpl) → 05 golang → 06 bun → 07 lua → 99 setup_macos`。`run_onchange_*` はファイルハッシュが変わったときだけ再実行（フォント / sbarlua / prezto / nvchad のセットアップ）。

## ディレクトリ構成（big picture）

```
.
├── install.sh                              # ブートストラップ (Xcode CLT → brew → chezmoi init)
├── .chezmoiroot                            # → "home"
├── .stylua.toml                            # Lua フォーマッタ設定 (col 120 / 2 space)
├── .claude/
│   ├── settings.json                       # 許可: chezmoi-apply / create-pr スキル系のみ
│   ├── skills/{chezmoi-apply,create-pr}/   # スクリプト + SKILL.md
│   └── rules/sketchybar-*.md               # sketchybar 編集時のリファレンス
└── home/                                   # ← chezmoi source dir (.chezmoiroot)
    ├── .chezmoiignore / .chezmoiexternal.toml
    ├── .chezmoiscripts/                    # 番号順ブートストラップ
    ├── dot_claude/{settings.json.tmpl,CLAUDE.md}   # Claude Code のグローバル設定 (~/.claude)
    ├── dot_config/
    │   ├── homebrew/Brewfile.tmpl          # brew bundle のソース
    │   ├── sketchybar/                     # Lua + C helper（後述）
    │   ├── nvim/                           # NvChad ベース（custom/ がユーザ拡張）
    │   ├── aerospace/ borders/ ccstatusline/ navi/ obsidian/ wezterm/
    ├── dot_zprezto/runcoms/zshrc.tmpl      # zsh (prezto)
    ├── private_dot_ssh/ private_Library/
    └── dot_local/share/
```

## sketchybar (`home/dot_config/sketchybar/`)

Lua ベースの構成（[sbarlua](https://github.com/FelixKratz/SbarLua) ランタイム）。
- エントリポイント: `executable_sketchybarrc.tmpl`（テンプレート処理後に `~/.config/sketchybar/sketchybarrc` として配置、shebang は `mise` 経由の Lua）。
- 構成 Lua: `init.lua` / `bar.lua` / `default.lua` / `colors.lua` / `icons.lua` / `settings.lua`。
- 個別アイテム: `items/*.lua`（spaces, calendar, media, menus, paw, apple, menu_apps）、ウィジェット: `items/widgets/{wifi,cpu,memory,battery}.lua`。
- C ヘルパ: `helpers/{makefile,menus/menus.c,event_providers/memory_load/*}` を `make` でコンパイルしてバイナリ生成（chezmoi の `run_onchange_after_install-sbarlua.sh` がランタイム導入を担当）。
- **編集時は `.claude/rules/sketchybar-*.md` を必ず参照すること。** 以下の論点ごとにルールが分離されている:
  - `sketchybar-bar.md` / `sketchybar-item-anatomy.md` / `sketchybar-item-properties.md`
  - `sketchybar-bracket-padding.md` / `sketchybar-overlay.md` / `sketchybar-y-offset.md`
  - `sketchybar-graph-divisor-cpu.md` / `sketchybar-graph-divisor-memory.md`
- フォーマッタは StyLua（`.stylua.toml`、120 桁 / 2 spaces / `AutoPreferDouble`）。

## Brewfile (`home/dot_config/homebrew/Brewfile.tmpl`)

CLI/cask/font の中央管理。編集後は `chezmoi-apply` で `~/.config/homebrew/Brewfile` を反映 → `run_after_01_install-brew-bundle.sh`（`brew bundle --global` を呼ぶ）が走る。テンプレートなのでホスト分岐したい場合は Go template 構文で書く。

## PR 作成フロー (`create-pr` スキル)

ブランチ作成 → コミット → push → PR の流れをスクリプト化。詳細は `.claude/skills/create-pr/SKILL.md`。

```bash
# Claude Code 内では: /create-pr もしくは /create-pr --merge
# ステップ実行:
.claude/skills/create-pr/scripts/status.sh        # 1. 状態確認
.claude/skills/create-pr/scripts/commit.sh        # 3. ブランチ作成 & コミット
.claude/skills/create-pr/scripts/push.sh          # 4. push (main/master 直は拒否)
.claude/skills/create-pr/scripts/create-pr.sh     # 5. gh pr create
.claude/skills/create-pr/scripts/merge.sh <PR#>   # 6. (オプション) マージ
```

## ローカル運用上の注意

- chezmoi の sourceDir はホストの `~/.local/share/chezmoi`（= **main worktree 固定**）。`chezmoi apply` で動作確認するタスクは worktree を切らず main で作業すること。`home/` のソース編集だけで完結する純粋な編集タスクは worktree でも可。
- 大きな変更はディレクトリ単位で段階的に `apply.sh` する（`SKILL.md` の推奨）。
- リポジトリには README / lint タスク / CI（GitHub Actions）は存在しない。検証は実機での `chezmoi diff` → `apply` → 各ツール再起動（sketchybar / aerospace / yabai 等）で行う。
