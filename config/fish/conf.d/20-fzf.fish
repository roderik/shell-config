# FZF Configuration
# Fuzzy finder setup and defaults

if command -q fzf
    # Set up fzf key bindings and fuzzy completion
    fzf --fish | source

    # Custom FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
end