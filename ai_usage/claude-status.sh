#!/usr/bin/env bash
cache="$HOME/.claude/tmux-status-cache.json"
[[ -f "$cache" ]] || exit 0

stale=false
if [[ $(( $(date +%s) - $(stat -f %m "$cache") )) -gt 300 ]]; then stale=true; fi

five_hour=$(jq -r '.rate_limits.five_hour.used_percentage // empty' "$cache" 2>/dev/null)
seven_day=$(jq -r '.rate_limits.seven_day.used_percentage // empty' "$cache" 2>/dev/null)

[[ -z "$five_hour" && -z "$seven_day" ]] && exit 0

parts=""
[[ -n "$five_hour" ]] && parts="5h:$(printf '%.0f' "$five_hour")%"
[[ -n "$seven_day" ]] && parts="${parts:+$parts }7d:$(printf '%.0f' "$seven_day")%"

if $stale; then
    pink=$(tmux display-message -p "#{@thm_pink}" 2>/dev/null || echo "#f5c2e7")
    printf "#[fg=%s] %s" "$pink" "$parts"
else
    printf " %s" "$parts"
fi
