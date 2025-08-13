#!/bin/bash
# Bash Configuration
# Modern shell setup with powerful CLI tools

# Source modular configuration if available
if [[ -d ~/.config/bash/conf.d ]]; then
  for config in ~/.config/bash/conf.d/*.bash; do
    [[ -f "$config" ]] && source "$config"
  done
fi

# Homebrew setup (detects M-series vs Intel Macs)
if [[ -e /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -e /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Fast Node Manager
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# 1Password CLI completion
if command -v op >/dev/null 2>&1; then
  eval "$(op completion bash)"
fi

# Environment variables
export NODE_NO_WARNINGS=1
export EDITOR=nvim
export VISUAL=nvim

# FZF configuration
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
fi

# Modern command aliases
alias ls='eza -lh --group-directories-first'
alias l='eza --git-ignore --group-directories-first'
alias ll='eza --all --header --long --group-directories-first'
alias llm='eza --all --header --long --sort=modified --group-directories-first'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias n='nvim'
alias vim='nvim'
alias exa='eza'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gcm='git commit --message'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glo='git log --oneline --decorate'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpr='git pull --rebase'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grs='git restore'
alias grss='git restore --staged'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsw='git switch'
alias gswc='git switch --create'
alias gcad='git commit --all --amend'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias lzd='lazydocker'
alias lzg='lazygit'

# Directory navigation
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Git functions
dockerclean() {
  # Remove stopped containers
  local containers=$(docker ps -a -q)
  if [[ -n "$containers" ]]; then
    docker rm $containers
  fi
  
  # Remove unused images
  local images=$(docker images -q)
  if [[ -n "$images" ]]; then
    docker rmi $images
  fi
  
  # Remove dangling volumes
  local volumes=$(docker volume ls -f dangling=true -q)
  if [[ -n "$volumes" ]]; then
    docker volume rm $volumes
  fi
}

gclean() {
  git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
}

gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*$)" | command xargs git branch -d 2>/dev/null
}

gfg() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for this function"
    return 1
  fi
  
  local branch=$(git branch -a | grep -v HEAD | sed 's/^[* ]*//' | fzf --height 20% --reverse --info=inline)
  if [[ -n "$branch" ]]; then
    git checkout $(echo "$branch" | sed "s#remotes/[^/]*/##")
  fi
}

glog() {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# AI Tool functions
claude() {
  local args=("$@")
  local extra_args=()
  
  if [[ -f .claude/AUTO_PLAN_MODE.txt ]]; then
    local prompt_content=$(cat .claude/AUTO_PLAN_MODE.txt)
    extra_args+=("--append-system-prompt" "$prompt_content")
  fi
  
  if command -v vt >/dev/null 2>&1; then
    vt -q claude --dangerously-skip-permissions "${extra_args[@]}" "${args[@]}"
  else
    command claude --dangerously-skip-permissions "${extra_args[@]}" "${args[@]}"
  fi
}

codex() {
  if command -v vt >/dev/null 2>&1; then
    vt -q codex --dangerously-bypass-approvals-and-sandbox "$@"
  else
    command codex --dangerously-bypass-approvals-and-sandbox "$@"
  fi
}

cursor-agent() {
  if command -v vt >/dev/null 2>&1; then
    vt -q cursor-agent -f "$@"
  else
    command cursor-agent -f "$@"
  fi
}

gemini() {
  if command -v vt >/dev/null 2>&1; then
    vt -q gemini -y "$@"
  else
    command gemini -y "$@"
  fi
}

# Path configurations
# Note: Bun and Foundry are installed via Homebrew
# Their paths are automatically handled by brew shellenv

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi

# Kubernetes krew
if [[ -d "$HOME/.krew/bin" ]]; then
  export PATH="$HOME/.krew/bin:$PATH"
fi

# User local bin
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Modern shell enhancements
# direnv - Per-project environment variables
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# zoxide - Smarter cd command
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias cd='z'
  alias cdi='zi'
fi

# atuin - Better shell history
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi

# Initialize Starship prompt if available
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# User-specific configuration
if [[ -f ~/.config/bash/user_config.bash ]]; then
  source ~/.config/bash/user_config.bash
fi