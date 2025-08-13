#!/usr/bin/env bash
# Git Functions
# Custom git utilities and helper functions

gclean() {
  # Remove local branches that have been merged
  git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
}

gbda() {
  # Delete all branches that have been merged into main/master
  git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*\$)" | command xargs git branch -d 2>/dev/null
}

gfg() {
  # Fuzzy find and checkout git branch
  if ! command -v fzf &> /dev/null; then
    echo "fzf is required for this function"
    return 1
  fi
  
  local branch
  branch=$(git branch -a | grep -v HEAD | sed 's/^[[:space:]]*//' | fzf --height 20% --reverse --info=inline)
  if [[ -n "$branch" ]]; then
    git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
  fi
}

glog() {
  # Pretty git log with graph
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}