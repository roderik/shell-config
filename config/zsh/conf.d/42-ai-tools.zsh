# AI Tool Functions

# Claude function with AUTO_PLAN_MODE support
claude() {
  local args=("$@")
  local extra_args=()
  
  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if [[ -f .claude/AUTO_PLAN_MODE.txt ]]; then
    # Use the file content as system prompt
    local prompt_content=$(cat .claude/AUTO_PLAN_MODE.txt)
    extra_args+=("--append-system-prompt" "$prompt_content")
  fi
  
  # Check if vt command exists
  if command -v vt >/dev/null 2>&1; then
    vt -q claude --dangerously-skip-permissions "${extra_args[@]}" "${args[@]}"
  else
    command claude --dangerously-skip-permissions "${extra_args[@]}" "${args[@]}"
  fi
}

# Codex function
codex() {
  if command -v vt >/dev/null 2>&1; then
    vt -q codex --dangerously-bypass-approvals-and-sandbox "$@"
  else
    command codex --dangerously-bypass-approvals-and-sandbox "$@"
  fi
}

# Cursor Agent function
cursor-agent() {
  if command -v vt >/dev/null 2>&1; then
    vt -q cursor-agent -f "$@"
  else
    command cursor-agent -f "$@"
  fi
}

# Gemini function
gemini() {
  if command -v vt >/dev/null 2>&1; then
    vt -q gemini -y "$@"
  else
    command gemini -y "$@"
  fi
}