#!/bin/bash
# Statusline script for Claude Pro — 3 lines: cwd + model/context + rate limits/extra-usage balance
# Reads JSON injected by Claude Code via stdin

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-quota"
BALANCE_CACHE="$CACHE_DIR/balance"
BALANCE_TTL=300

# --refresh-balance: internal mode, fetches the prepaid credit balance into the cache
if [[ "$1" == "--refresh-balance" ]]; then
  mkdir -p "$CACHE_DIR"
  org=$(jq -r '.oauthAccount.organizationUuid // empty' "$HOME/.claude.json" 2>/dev/null)
  tok=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
        | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  [[ -z "$org" || -z "$tok" ]] && exit 0
  resp=$(curl -s -m 10 \
    "https://api.anthropic.com/api/oauth/organizations/$org/prepaid/credits" \
    -H "Authorization: Bearer $tok" -H "Content-Type: application/json" 2>/dev/null)
  cents=$(echo "$resp" | jq -r '.amount // empty' 2>/dev/null)
  if [[ "$cents" =~ ^-?[0-9]+$ ]]; then
    printf '%s\n' "$cents" > "$BALANCE_CACHE.tmp" && mv "$BALANCE_CACHE.tmp" "$BALANCE_CACHE"
  else
    # keep the stale value but bump mtime so we don't hammer the API on failure
    [[ -f "$BALANCE_CACHE" ]] && touch "$BALANCE_CACHE"
  fi
  exit 0
fi

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
five_h_resets=""
seven_d_resets=""
cost_usd=""
cwd=""

if [[ ! -t 0 ]]; then
  input=$(cat 2>/dev/null || true)
  if [[ -n "$input" ]]; then
    cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
    ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
    ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
    ctx_tokens=$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0)' 2>/dev/null)
    model_name=$(echo "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)
    five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
    seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
    five_h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
    seven_d_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)
    cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
  fi
fi

render_bar() {
  local pct="${1%.*}"
  pct=${pct:-0}
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100

  if [[ "$MODE" == "text" ]]; then
    printf "%s%%" "$pct"
    return
  fi

  local filled=$(( (pct + 5) / 10 ))
  local empty=$(( 10 - filled ))
  (( filled > 10 )) && filled=10
  local bar=""
  for (( j=0; j<filled; j++ )); do bar+="█"; done
  for (( j=0; j<empty; j++ )); do bar+="░"; done
  printf "%s %s%%" "$bar" "$pct"
}

render_reset() {
  local ts="$1"
  [[ -z "$ts" ]] && return
  local now diff
  now=$(date +%s)
  diff=$(( ts - now ))
  (( diff <= 0 )) && printf '~0' && return
  local h=$(( diff / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if (( h > 0 )); then
    printf '%dh%02d' "$h" "$m"
  else
    printf '%d' "$m"
  fi
}

# Extra-usage balance: read from cache, refresh in background when stale
read_balance() {
  local now mtime age
  now=$(date +%s)
  if [[ -f "$BALANCE_CACHE" ]]; then
    mtime=$(stat -f %m "$BALANCE_CACHE" 2>/dev/null || stat -c %Y "$BALANCE_CACHE" 2>/dev/null)
    age=$(( now - ${mtime:-0} ))
    cat "$BALANCE_CACHE" 2>/dev/null
  else
    age=$(( BALANCE_TTL + 1 ))
  fi
  if (( age > BALANCE_TTL )); then
    ( "$0" --refresh-balance >/dev/null 2>&1 & ) &
  fi
}
balance_cents=$(read_balance)

ctx_real_pct=""
if [[ -n "$ctx_tokens" && -n "$ctx_total" && "$ctx_total" -gt 0 ]]; then
  ctx_real_pct=$(( ctx_tokens * 100 / ctx_total ))
fi

# ── Line 1: cwd │ context bar │ token count │ /compact hint
line1=""
sep1=false
if [[ -n "$cwd" ]]; then
  line1+="/${cwd##*/}"
  sep1=true
fi
if [[ -n "$ctx_real_pct" ]]; then
  $sep1 && line1+=" │ "
  line1+="Ctx:$(render_bar "$ctx_real_pct")"
  sep1=true
  if [[ -n "$ctx_tokens" && -n "$ctx_total" ]]; then
    ctx_k=$(( ctx_tokens / 1000 ))
    ctx_max_k=$(( ctx_total / 1000 ))
    line1+=" │ ${ctx_k}k/${ctx_max_k}k"
  fi
  if (( ctx_real_pct >= 50 )); then
    line1+=" │ ⚡ /compact"
  fi
fi

# ── Line 2: 5h window │ 7d window
line2=""
sep2=false
if [[ -n "$five_h" ]]; then
  line2+="5h:$(render_bar "$five_h")"
  [[ -n "$five_h_resets" ]] && line2+=" ↺$(render_reset "$five_h_resets")"
  sep2=true
fi
if [[ -n "$seven_d" ]]; then
  $sep2 && line2+=" │ "
  line2+="7j:$(render_bar "$seven_d")"
  [[ -n "$seven_d_resets" ]] && line2+=" ↺$(render_reset "$seven_d_resets")"
  sep2=true
fi

# ── Line 3: model │ extra usage spent │ extra usage balance
line3=""
sep3=false
if [[ -n "$model_name" ]]; then
  line3+="◆ ${model_name}"
  sep3=true
fi
if [[ -n "$cost_usd" ]]; then
  $sep3 && line3+=" │ "
  line3+="\$$(printf '%.4f' "$cost_usd" 2>/dev/null)"
  sep3=true
fi
if [[ "$balance_cents" =~ ^-?[0-9]+$ ]]; then
  $sep3 && line3+=" │ "
  line3+="\$$(awk -v c="$balance_cents" 'BEGIN{printf "%.2f", c/100}')"
fi

for l in "$line1" "$line2" "$line3"; do
  [[ -n "$l" ]] && printf '%s\n' "$l"
done
