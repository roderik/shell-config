# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, zoxide, atuin

# direnv - Per-project environment variables
if command -q direnv
    direnv hook fish | source
end

# zoxide - Smarter cd command
if command -q zoxide
    zoxide init fish | source
    alias cd='z'
    alias cdi='zi' # interactive selection
end

# atuin - Better shell history
if command -q atuin
    atuin init fish | source
end