#!/usr/bin/env bash
# Completions and Integrations

# Initialize Starship prompt
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Initialize zoxide
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Initialize atuin
if command -v atuin > /dev/null 2>&1; then
  eval "$(atuin init bash)"
fi

# Initialize direnv
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Initialize fnm
if command -v fnm > /dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# FZF key bindings
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.bash
elif [[ -f /usr/local/opt/fzf/shell/key-bindings.bash ]]; then
  source /usr/local/opt/fzf/shell/key-bindings.bash
fi