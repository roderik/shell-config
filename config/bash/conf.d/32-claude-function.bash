#!/usr/bin/env bash
# Claude Function
# Custom Claude Code wrapper with auto-detection of project settings

claude() {
  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if [[ -f .claude/AUTO_PLAN_MODE.txt ]]; then
    # Use the file content as system prompt
    local prompt_content=$(cat .claude/AUTO_PLAN_MODE.txt)
    if command -v vt &> /dev/null; then
      vt -q claude --dangerously-skip-permissions --append-system-prompt "$prompt_content" "$@"
    else
      command claude --dangerously-skip-permissions --append-system-prompt "$prompt_content" "$@"
    fi
  else
    # Run normally without the append-system-prompt
    if command -v vt &> /dev/null; then
      vt -q claude --dangerously-skip-permissions "$@"
    else
      command claude --dangerously-skip-permissions "$@"
    fi
  fi
}