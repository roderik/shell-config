# Git Functions
# Custom git utilities and helper functions

function gclean --description 'Remove local branches that have been merged'
    git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
end

function gbda --description 'Delete all branches that have been merged into main/master'
    git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*\$)" | command xargs git branch -d 2>/dev/null
end

function gfg --description 'Fuzzy find and checkout git branch'
    if not command -q fzf
        echo "fzf is required for this function"
        return 1
    end

    set -l branch (git branch -a | grep -v HEAD | string trim | fzf --height 20% --reverse --info=inline)
    if test -n "$branch"
        git checkout (echo $branch | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    end
end

function glog --description 'Pretty git log with graph'
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
end