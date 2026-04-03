#!/bin/bash
# chezmoi status for specified target path(s)
# Usage: status.sh [target_path...]
# Shows which files have changes (A=added, M=modified, D=deleted, R=replaced)

set -euo pipefail

if ! command -v chezmoi &>/dev/null; then
  echo "Error: chezmoi command not found" >&2
  exit 2
fi

if [ $# -eq 0 ]; then
  chezmoi status 2>&1
else
  chezmoi status "$@" 2>&1
fi
