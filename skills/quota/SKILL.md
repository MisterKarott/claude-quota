---
name: quota
description: This skill is triggered when the user runs "/quota" or asks to "check my quota", "show quota", "how much quota left", "Claude usage", "Claude Pro usage". Displays a formatted view of current Claude Pro rate limit usage.
allowed-tools:
  - Bash
  - Read
---

## Purpose

Display a clear, formatted breakdown of Claude Pro rate limit usage for the current session.

## When to use

Trigger on `/quota` slash command or when the user explicitly asks about their current Claude Pro quota, usage, or rate limits.

## Procedure

### 1. Check mode

If `ANTHROPIC_BASE_URL` contains `api.z.ai` or `bigmodel.cn`, this is GLM mode — inform the user this skill is for Claude Pro and stop.

### 2. Read the statusline data

Run the statusline script in text mode to get the current values:

```bash
echo '{}' | bash "${CLAUDE_PLUGIN_ROOT}/scripts/quota-statusline.sh" --mode text
```

Note: This returns empty if Claude Code hasn't passed rate limit data yet (only populated after the first turn).

### 3. Display the formatted output

Format the available data as a box table:

```
╔══════════════════════════════════════╗
║      Claude Pro — Usage             ║
╠══════════════════════════════════════╣
║ Tokens (5h)    ██████░░░░  62%      ║
║ Tokens (7j)    ███░░░░░░░  28%      ║
║ Session cost   $0.0234              ║
╠══════════════════════════════════════╣
║ Status: OK (highest: 62%)           ║
╚══════════════════════════════════════╝
```

Use the same color thresholds as the statusline: green < 70%, yellow 70–90%, red ≥ 90%.

### 4. Explain the limits

Claude Pro rate limits:
- **5-hour window**: rolling token usage over the last 5 hours
- **7-day window**: rolling token usage over the last 7 days
- Reset times are not available via API — check claude.ai/settings/plans for details

### Edge cases

- No data yet → "Rate limit data not available yet. It appears after the first model turn."
- GLM mode detected → "This skill is for Claude Pro. In GLM mode, use `/glm-quota:quota`."
