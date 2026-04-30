#!/bin/bash
# Statusline script for Claude Pro — 2 lines: model/context + rate limits/cost
# Reads JSON injected by Claude Code via stdin

MODE="bar"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

ctx_pct=""
ctx_tokens=""
ctx_total=""
model_name=""
five_h=""
seven_d=""
cost_usd=""

if [[ ! -t 0 ]]; then
  input=$(cat 2>/dev/null || true)
  if [[ -n "$input" ]]; then
    ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
    ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
    ctx_tokens=$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0)' 2>/dev/null)
    model_name=$(echo "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)
    five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
    seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
    cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
  fi
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
  (( filled > 10 )) && filled=10
  local bar=""
  for (( j=0; j<filled; j++ )); do bar+="█"; done
  for (( j=0; j<empty; j++ )); do bar+="░"; done
  printf "${color}%s %s%%${reset}" "$bar" "$pct"
}

# Compute real context % from token counts (more accurate than used_percentage)
ctx_real_pct=""
if [[ -n "$ctx_tokens" && -n "$ctx_total" && "$ctx_total" -gt 0 ]]; then
  ctx_real_pct=$(( ctx_tokens * 100 / ctx_total ))
fi

# Line 1: model + context bar + token count + /compact hint
line1="◆"
if [[ -n "$model_name" ]]; then
  line1+=" ${model_name}"
fi
if [[ -n "$ctx_real_pct" ]]; then
  line1+=" \e[2m│\e[0m Ctx:$(render_bar "$ctx_real_pct")"
  if [[ -n "$ctx_tokens" && -n "$ctx_total" ]]; then
    ctx_k=$(( ctx_tokens / 1000 ))
    ctx_max_k=$(( ctx_total / 1000 ))
    line1+=" \e[2m│ ${ctx_k}k/${ctx_max_k}k\e[0m"
  fi
  if (( ctx_real_pct >= 50 )); then
    line1+=" \e[2m│\e[0m \e[33m⚡ /compact\e[0m"
  fi
fi

# Line 2: rate limits + cost
line2="  "
sep=false
if [[ -n "$five_h" ]]; then
  line2+="5h:$(render_bar "$five_h")"
  sep=true
fi
if [[ -n "$seven_d" ]]; then
  $sep && line2+=" \e[2m│\e[0m "
  line2+="7j:$(render_bar "$seven_d")"
  sep=true
fi
if [[ -n "$cost_usd" ]]; then
  $sep && line2+=" \e[2m│\e[0m "
  cost_fmt=$(printf '%.4f' "$cost_usd" 2>/dev/null)
  line2+="\e[2m\$${cost_fmt}\e[0m"
fi

printf '%b\n%b\n' "$line1" "$line2"
