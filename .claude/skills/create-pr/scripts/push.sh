#!/bin/bash
# 現在のブランチをリモートにプッシュする
# Usage: push.sh

set -euo pipefail

branch_name=$(git branch --show-current)

if [ "$branch_name" = "main" ] || [ "$branch_name" = "master" ]; then
  echo "Error: cannot push directly to $branch_name" >&2
  exit 1
fi

echo "=== Pushing branch: $branch_name ==="
git push -u origin "$branch_name"

echo ""
echo "Pushed: $branch_name"
