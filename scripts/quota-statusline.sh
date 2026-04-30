#!/bin/bash
# Statusline script for Claude Pro — reads rate limits injected by Claude Code via stdin
# Displays token usage windows and session cost with color coding

MODE="bar"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

five_h=""
seven_d=""
cost_usd=""

if [[ ! -t 0 ]]; then
  input=$(timeout 1 cat 2>/dev/null || true)
  if [[ -n "$input" ]]; then
    five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
    seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
    cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
  fi
fi

if [[ -z "$five_h" && -z "$seven_d" && -z "$cost_usd" ]]; then
  echo ""
  exit 0
fi

render_bar() {
  local pct="${1%.*}"
  pct=${pct:-0}
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100

  local color reset='\e[0m'
  if (( pct >= 90 )); then color='\e[31m'
  elif (( pct >= 70 )); then color='\e[33m'
  else color='\e[32m'
  fi

  if [[ "$MODE" == "text" ]]; then
    printf "${color}%s%%${reset}" "$pct"
    return
  fi

  local filled=$(( (pct + 5) / 10 ))
  local empty=$(( 10 - filled ))
  local bar=""
  for (( j=0; j<filled; j++ )); do bar+="█"; done
  for (( j=0; j<empty; j++ )); do bar+="░"; done
  printf "${color}%s %s%%${reset}" "$bar" "$pct"
}

output="◆ "
sep=false

if [[ -n "$five_h" ]]; then
  output+="5h:$(render_bar "$five_h")"
  sep=true
fi
if [[ -n "$seven_d" ]]; then
  $sep && output+=" \e[2m│\e[0m "
  output+="7j:$(render_bar "$seven_d")"
  sep=true
fi
if [[ -n "$cost_usd" ]]; then
  $sep && output+=" \e[2m│\e[0m "
  cost_fmt=$(printf '%.4f' "$cost_usd" 2>/dev/null)
  output+="\e[2m\$${cost_fmt}\e[0m"
fi

printf '%b\n' "$output"
