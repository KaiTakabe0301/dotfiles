#!/bin/bash
# 現在のgit状態を一括表示する
# Usage: status.sh
# 出力: ステータス、差分、直近コミット履歴

set -euo pipefail

echo "=== Git Status ==="
git status -u

echo ""
echo "=== Staged Changes ==="
git diff --cached

echo ""
echo "=== Unstaged Changes ==="
git diff

echo ""
echo "=== Recent Commits ==="
git log --oneline -5
