#!/usr/bin/env zsh
# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, zoxide, atuin

# direnv - Per-project environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# zoxide - Smarter cd command
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # Create cd as a function that calls z to avoid alias expansion issues
  function cd() {
    z "$@"
  }
  alias cdi='zi' # interactive selection
fi

# atuin - Better shell history
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi