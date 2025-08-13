# Aliases

# File operations with modern tools
alias ls='eza'
alias ll='eza -alh'
alias la='eza -a'
alias lt='eza --tree'
alias cat='bat'

# Git shortcuts
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git log'
alias gp='git push'
alias gpu='git pull'
alias gst='git status'

# Tool shortcuts
alias lzg='lazygit'
alias lzd='lazydocker'
alias ff='fzf --preview "bat --color=always {}"'
alias cdi='zi'  # zoxide interactive
alias claude='claude --skip-permissions'

# Common operations
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Search and find
alias grep='rg'
alias find='fd'

# System
alias reload='source ~/.zshrc'
alias zshconfig='$EDITOR ~/.zshrc'
alias zshlocal='$EDITOR ~/.zshrc.local'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Network
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# Development
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias flushdns='sudo dscacheutil -flushcache'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
fi