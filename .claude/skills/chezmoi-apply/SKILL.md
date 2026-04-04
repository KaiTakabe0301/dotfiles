---
name: chezmoi-apply
description: |
  chezmoi の更新差分を確認し、指定したパスの範囲だけを選択的に反映するスキル。
  全体を apply するのではなく、特定のディレクトリやファイルだけを対象にできる。
  トリガー: "chezmoi apply", "chezmoi 反映", "dotfiles 反映", "設定を反映",
  "chezmoi diff", "chezmoi 差分", "dotfiles 更新", "設定ファイルを更新",
  "chezmoi status", "chezmoi の変更確認", "dotfiles の差分",
  "nvim の設定を反映", "zsh の設定を反映", "git の設定を反映",
  "部分的に apply", "一部だけ反映"
allowed-tools:
  - "Bash(.claude/skills/chezmoi-apply/scripts/*)"
---

# chezmoi-apply

chezmoi の更新差分を確認し、指定したパス範囲のみを選択的に反映するスキル。

## ワークフロー

以下の手順で進める:

### Step 1: 変更状態の確認

まず `status.sh` で変更があるファイルの一覧を取得する。

```bash
# 全体の変更状態を確認
.claude/skills/chezmoi-apply/scripts/status.sh

# 特定パスの変更状態を確認
.claude/skills/chezmoi-apply/scripts/status.sh ~/.config/nvim/
```

ステータスの意味:
- `A` = 追加 (Added)
- `M` = 変更 (Modified)
- `D` = 削除 (Deleted)
- `R` = 置換 (Replaced)

### Step 2: 差分の確認

変更内容の詳細を `diff.sh` で確認する。

```bash
# 全体の差分を確認
.claude/skills/chezmoi-apply/scripts/diff.sh

# 特定パスの差分を確認
.claude/skills/chezmoi-apply/scripts/diff.sh ~/.config/nvim/
.claude/skills/chezmoi-apply/scripts/diff.sh ~/.config/git/config
```

### Step 3: ユーザーに確認

差分の内容をユーザーに提示し、反映してよいか確認を取る。
**apply は破壊的操作（既存ファイルを上書き）なので、必ずユーザーの承認を得てから実行すること。**

### Step 4: 選択的に反映

ユーザーが承認したパスのみを `apply.sh` で反映する。

```bash
# 特定ディレクトリだけ反映
.claude/skills/chezmoi-apply/scripts/apply.sh ~/.config/nvim/

# 特定ファイルだけ反映
.claude/skills/chezmoi-apply/scripts/apply.sh ~/.config/git/config

# 複数パスを同時に反映
.claude/skills/chezmoi-apply/scripts/apply.sh ~/.config/nvim/ ~/.zshrc
```

## パス指定のパターン

chezmoi apply のターゲットパスはホームディレクトリ配下の実際のパス（デスティネーションパス）を指定する:

| 対象 | パス例 |
|------|--------|
| nvim 設定全体 | `~/.config/nvim/` |
| 特定の nvim ファイル | `~/.config/nvim/lua/custom/plugins/init.lua` |
| zsh 設定 | `~/.zshrc` |
| git 設定 | `~/.config/git/config` |
| lazygit 設定 | `~/.config/lazygit/` |
| tmux 設定 | `~/.config/tmux/` |

## 注意事項

- **chezmoi コマンドは絶対に直接実行しないこと。必ずスクリプト経由で実行すること。**
  - `chezmoi status` → `.claude/skills/chezmoi-apply/scripts/status.sh`
  - `chezmoi diff` → `.claude/skills/chezmoi-apply/scripts/diff.sh`
  - `chezmoi apply` → `.claude/skills/chezmoi-apply/scripts/apply.sh`
  - 理由: chezmoi コマンドには `--include=files` や `--pager ""` などのフラグが必要だが、`=` やクォート文字を含むフラグを Bash ツールで直接実行すると権限確認プロンプトが発生する。スクリプト内でフラグを処理することでこの問題を回避する。
- **スクリプトは必ず相対パスで呼び出すこと**（`settings.json` の許可パターンが相対パスで定義されているため、絶対パスだとマッチせず権限確認が発生する）
- `apply.sh` は引数なし（全体 apply）を許可していない。必ずターゲットパスを指定すること
- 差分が大きい場合はディレクトリ単位で段階的に反映することを推奨
- 反映後に問題があれば `.claude/skills/chezmoi-apply/scripts/diff.sh` で再度状態を確認できる
