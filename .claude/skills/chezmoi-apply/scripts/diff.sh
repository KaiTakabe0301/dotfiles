#!/bin/bash
# chezmoi diff for specified target path(s)
# Usage: diff.sh [target_path...]
# If no path is given, shows all diffs.

set -euo pipefail

if ! command -v chezmoi &>/dev/null; then
  echo "Error: chezmoi command not found" >&2
  exit 2
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

if [ $# -eq 0 ]; then
  chezmoi -S "$SOURCE_DIR" diff --pager "" 2>&1
else
  chezmoi -S "$SOURCE_DIR" diff --pager "" "$@" 2>&1
fi
