# Aliases

# File operations with modern tools
alias ls='eza'
alias ll='eza -alh'
alias la='eza -a'
alias lt='eza --tree'
alias cat='bat'
alias sg='ast-grep'

# Git shortcuts (in addition to abbreviations)
alias g='git'
alias lzg='lazygit'
alias lzd='lazydocker'

# Tool shortcuts
alias ff='fzf --preview "bat --color=always {}"'
alias cd='z'
alias cdi='zi'
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
alias reload='source ~/.config/fish/config.fish'
alias fishconfig='$EDITOR ~/.config/fish/config.fish'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Network
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# macOS specific
alias brewup='brew update && brew upgrade && brew cleanup'
alias flushdns='sudo dscacheutil -flushcache'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'