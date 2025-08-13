#!/usr/bin/env bash
# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, zoxide, atuin

# direnv - Per-project environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi

# zoxide - Smarter cd command
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
  alias cd='z'
  alias cdi='zi' # interactive selection
fi

# atuin - Better shell history
if command -v atuin &> /dev/null; then
  eval "$(atuin init bash)"
fi