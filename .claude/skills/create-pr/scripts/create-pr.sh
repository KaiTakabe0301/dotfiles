#!/bin/bash
# PRを作成する（--body-file方式）
# Usage: create-pr.sh <title> <body-file>
#   body-file: PR本文が書かれたファイルのパス

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Error: title and body-file are required" >&2
  echo "Usage: create-pr.sh <title> <body-file>" >&2
  exit 1
fi

title="$1"
body_file="$2"

if [ ! -f "$body_file" ]; then
  echo "Error: body file not found: $body_file" >&2
  exit 1
fi

echo "=== Creating Pull Request ==="
pr_url=$(gh pr create --title "$title" --body-file "$body_file")

# ボディファイルを削除
rm -f "$body_file"

echo ""
echo "PR created: $pr_url"
