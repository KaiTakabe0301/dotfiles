#!/bin/bash
# PRをマージしてブランチを削除し、mainに戻る
# Usage: merge.sh <pr-number>

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Error: PR number is required" >&2
  echo "Usage: merge.sh <pr-number>" >&2
  exit 1
fi

pr_number="$1"

echo "=== Merging PR #${pr_number} ==="
gh pr merge "$pr_number" --merge --delete-branch

echo ""
echo "PR #${pr_number} merged and branch deleted."
