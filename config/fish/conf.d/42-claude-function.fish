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