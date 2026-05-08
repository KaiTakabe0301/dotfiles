#!/bin/bash
# chezmoi apply for specified target path(s)
# Usage: apply.sh <target_path> [target_path...]

set -euo pipefail

if ! command -v chezmoi &>/dev/null; then
  echo "Error: chezmoi command not found" >&2
  exit 2
fi

if [ $# -eq 0 ]; then
  echo "Error: target path is required" >&2
  echo "Usage: apply.sh <target_path> [target_path...]" >&2
  exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

chezmoi -S "$SOURCE_DIR" apply "$@" 2>&1
echo "chezmoi apply completed for: $* (source: $SOURCE_DIR)"
