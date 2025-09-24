# Claude Function
# Custom Claude Code wrapper with auto-detection of project settings

function claude --description 'Claude Code with skip permissions'
  # Check if .claude/AUTO_PLAN_MODE.txt exists in current directory
  if test -f .claude/AUTO_PLAN_MODE.txt
    # Use the file content as system prompt
    if command -q vt
      vt -q claude --dangerously-skip-permissions --append-system-prompt (cat .claude/AUTO_PLAN_MODE.txt | string collect) $argv
    else
      command claude --dangerously-skip-permissions --append-system-prompt (cat .claude/AUTO_PLAN_MODE.txt | string collect) $argv
    end
  else
    # Run normally without the append-system-prompt
    if command -q vt
      vt -q claude --dangerously-skip-permissions $argv
    else
      command claude --dangerously-skip-permissions $argv
    end
  end
end

function opencode --description 'Opencode wrapper'
  if command -q vt
    vt -q opencode $argv
  else
    command opencode $argv
  end
end

alias oc="opencode"

# Codex function
function codex --description 'Codex wrapper'
  if command -q vt
    vt -q codex --dangerously-bypass-approvals-and-sandbox $argv
  else
    command codex --dangerously-bypass-approvals-and-sandbox $argv
  end
end

# Cursor Agent function
function cursor-agent --description 'Cursor Agent wrapper'
  if command -q vt
    vt -q cursor-agent -f $argv
  else
    command cursor-agent -f $argv
  end
end

# Gemini function
function gemini --description 'Gemini wrapper'
  if command -q vt
    vt -q gemini -y $argv
  else
    command gemini -y $argv
  end
end
