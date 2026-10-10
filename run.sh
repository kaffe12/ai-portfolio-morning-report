#!/bin/zsh
export PATH="$HOME/.local/bin:/opt/anaconda3/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
cd "$HOME/Claude/morgenrapport"
echo "=== $(date) ===" >> logs/morgenrapport.log
claude -p "/morgenrapport" \
  --allowedTools "mcp__alphavantage" "WebSearch" "WebFetch" "Bash" "Read" "Write" "Edit" \
  >> logs/morgenrapport.log 2>&1