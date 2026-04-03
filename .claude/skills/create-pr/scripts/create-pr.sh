#!/bin/bash
# PRを作成する
# Usage: create-pr.sh <title> <body>

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Error: title and body are required" >&2
  echo "Usage: create-pr.sh <title> <body>" >&2
  exit 1
fi

title="$1"
body="$2"

echo "=== Creating Pull Request ==="
pr_url=$(gh pr create --title "$title" --body "$body")

echo ""
echo "PR created: $pr_url"
