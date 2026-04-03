---
name: create-pr
description: |
  現在の変更からブランチを作成し、コミット・プッシュ・PR作成・マージまでを一括で行うスキル。
  引数でマージの有無を制御できる。
  トリガー: "PR作成", "PRを作って", "プルリクエスト作成", "create PR",
  "PRを作成してマージ", "PR作ってマージして", "ブランチ作ってPR",
  "変更をPRにして", "create pull request"
allowed-tools:
  - "Bash(.claude/skills/create-pr/scripts/*)"
---

# create-pr

現在の変更からブランチ作成 → コミット → プッシュ → PR作成（→ オプションでマージ）を行うスキル。

## 引数

```
/create-pr                     # PR作成のみ
/create-pr --merge             # PR作成後にマージ
```

ARGUMENTS の中に `--merge`, `merge`, `マージ` が含まれている場合はマージも実行する。

## スクリプト一覧

| スクリプト | 用途 |
|-----------|------|
| `scripts/status.sh` | git status, diff, log を一括表示 |
| `scripts/commit.sh` | ブランチ作成 → ステージング → コミット |
| `scripts/push.sh` | 現在ブランチをリモートにプッシュ |
| `scripts/create-pr.sh` | gh で PR 作成 |
| `scripts/merge.sh` | PR マージ＆ブランチ削除 |

## ワークフロー

### Step 1: 現在の状態を確認

```bash
.claude/skills/create-pr/scripts/status.sh
```

変更がない場合はユーザーに通知して終了する。

### Step 2: 変更内容を分析してブランチ名・コミットメッセージを決定

Step 1 の出力から以下を自動決定する:

- **ブランチ名**: `feat/...`, `fix/...`, `refactor/...` などの conventional パターン
- **コミットメッセージ**: conventional commits 形式（`feat(scope): 説明`）
- **PRタイトル**: コミットメッセージと同じ
- **PR本文**: 変更内容のサマリー

このリポジトリの過去コミットのスタイルに合わせること。

### Step 3: ブランチ作成・コミット

```bash
.claude/skills/create-pr/scripts/commit.sh <branch-name> "<commit-message>" <file1> [file2...]
```

- ブランチ名、コミットメッセージ、対象ファイルを引数で渡す
- 機密ファイル（`.env`, `credentials`, `secret` 等）は自動で拒否される

### Step 4: プッシュ

```bash
.claude/skills/create-pr/scripts/push.sh
```

- main/master への直接プッシュは自動で拒否される

### Step 5: PR作成

まず Write ツールで PR 本文を一時ファイルに書き出し、そのパスをスクリプトに渡す。

```bash
# 1. Write ツールで pr-body.md に PR 本文を書き出す
# 2. スクリプトにファイルパスを渡す（スクリプトが使用後に自動削除する）
.claude/skills/create-pr/scripts/create-pr.sh "<title>" pr-body.md
```

- **PR 本文はシェル引数に直接渡さない**（マークダウンの `#` が権限チェックに引っかかるため）
- Write ツールで `pr-body.md` に本文を書き出してからスクリプトに渡す
- スクリプトが PR 作成後にボディファイルを自動削除する（追加のクリーンアップ不要）
- ボディは以下の形式にする:

```
## Summary
- 変更点1
- 変更点2

## Test plan
- [ ] テスト項目

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

PR URLをユーザーに表示する。

### Step 6: マージ（オプション）

`--merge` が指定されている場合のみ実行:

```bash
.claude/skills/create-pr/scripts/merge.sh <pr-number>
```

- PR番号は Step 5 の出力から取得する
- マージ後、ローカルを main に戻す（`git checkout main && git pull`）

## 注意事項

- **スクリプトは必ず相対パスで呼び出すこと**（`settings.json` の許可パターンが相対パスで定義されているため、絶対パスだとマッチせず権限確認が発生する）
- force push は絶対にしない
- PR作成前にユーザーに確認は不要（スキル呼び出し自体が意思表示）
- マージ前にもユーザー確認は不要（`--merge` 指定自体が意思表示）
