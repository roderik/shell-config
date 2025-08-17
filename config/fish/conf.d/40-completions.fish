# Completions and Integrations

# Initialize Starship prompt
if command -v starship > /dev/null
    starship init fish | source
end

# Initialize zoxide
if command -v zoxide > /dev/null
    zoxide init fish | source
end

# Initialize atuin
if command -v atuin > /dev/null
    atuin init fish | source
end

# Initialize direnv
if command -v direnv > /dev/null
    direnv hook fish | source
end

# FZF key bindings
if test -f /opt/homebrew/opt/fzf/shell/key-bindings.fish
    source /opt/homebrew/opt/fzf/shell/key-bindings.fish
else if test -f /usr/local/opt/fzf/shell/key-bindings.fish
    source /usr/local/opt/fzf/shell/key-bindings.fish
end