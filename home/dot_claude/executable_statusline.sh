#!/usr/bin/env bash
# Thin wrapper around ccstatusline that also feeds the sketchybar claude_usage
# widget. The stdin JSON from Claude Code is captured once, mined for the
# rate_limits object into a cache file (read by sketchybar), then forwarded
# verbatim to ccstatusline so the status line itself is unchanged.
#
# Every side-effect is best-effort and guarded with `|| true`: a failure here
# must never break the status line.
set -u

# Make brew-installed jq / sketchybar reachable even under a minimal PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Capture the full stdin payload once so it can be reused.
input="$(cat)"

cache_file="$HOME/.cache/claude-code-usage.json"

if command -v jq >/dev/null 2>&1; then
	rate_limits="$(printf '%s' "$input" | jq -c '.rate_limits // empty' 2>/dev/null)" || rate_limits=""
	if [ -n "$rate_limits" ]; then
		mkdir -p "$HOME/.cache" 2>/dev/null || true
		tmp="$(mktemp "${cache_file}.XXXXXX" 2>/dev/null)" || tmp=""
		if [ -n "$tmp" ]; then
			if printf '%s\n' "$rate_limits" >"$tmp" 2>/dev/null; then
				mv -f "$tmp" "$cache_file" 2>/dev/null || rm -f "$tmp" 2>/dev/null
			else
				rm -f "$tmp" 2>/dev/null
			fi
		fi
		if command -v sketchybar >/dev/null 2>&1; then
			sketchybar --trigger claude_usage_update >/dev/null 2>&1 || true
		fi
	fi
fi

# Forward the original payload to ccstatusline unchanged.
printf '%s' "$input" | bunx -y ccstatusline@latest
