#!/bin/bash
# ブランチ作成 → ファイルステージング → コミットを行う
# Usage: commit.sh <branch-name> <commit-message> <file1> [file2...]
# 例: commit.sh feat/flash-nvim "feat(nvim): flash.nvim導入" file1.lua file2.lua

set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Error: branch name, commit message, and at least one file are required" >&2
  echo "Usage: commit.sh <branch-name> <commit-message> <file1> [file2...]" >&2
  exit 1
fi

branch_name="$1"
commit_message="$2"
shift 2
files=("$@")

# 機密ファイルのチェック
for file in "${files[@]}"; do
  if echo "$file" | grep -qiE '\.env|credentials|secret|\.key$|\.pem$'; then
    echo "Error: potentially sensitive file detected: $file" >&2
    echo "Remove it from the file list or confirm manually." >&2
    exit 1
  fi
done

# ブランチ作成
echo "=== Creating branch: $branch_name ==="
git checkout -b "$branch_name"

# ファイルステージング
echo "=== Staging files ==="
for file in "${files[@]}"; do
  echo "  + $file"
  git add "$file"
done

# コミット
echo "=== Committing ==="
git commit -m "$(cat <<EOF
${commit_message}

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

echo ""
echo "Commit created on branch: $branch_name"
