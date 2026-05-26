#!/usr/bin/env bash
input=$(cat)
echo "$input" > "$HOME/.claude/tmux-status-cache.json"

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten the cwd: replace $HOME with ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

parts=""

# Working directory
if [ -n "$short_cwd" ]; then
  parts="$short_cwd"
fi

# Model name
if [ -n "$model" ]; then
  [ -n "$parts" ] && parts="$parts | "
  parts="${parts}${model}"
fi

# Context usage
if [ -n "$used_pct" ]; then
  formatted_pct=$(printf "%.0f" "$used_pct")
  [ -n "$parts" ] && parts="$parts | "
  parts="${parts}ctx: ${formatted_pct}%"
fi

# Rate limit usage (5-hour session limit and/or 7-day weekly limit)
rate_parts=""
if [ -n "$five_hour" ]; then
  rate_parts="5h: $(printf '%.0f' "$five_hour")%"
fi
if [ -n "$seven_day" ]; then
  [ -n "$rate_parts" ] && rate_parts="$rate_parts  "
  rate_parts="${rate_parts}7d: $(printf '%.0f' "$seven_day")%"
fi
if [ -n "$rate_parts" ]; then
  [ -n "$parts" ] && parts="$parts | "
  parts="${parts}${rate_parts}"
fi

printf "%s" "$parts"
