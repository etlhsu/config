autoload -U colors && colors

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

set -o vi
bindkey '\t' autosuggest-accept
setopt autocd

mkcd() {
   mkdir $1
   cd $1
}

checkgitenv() {
  if [ ! -d ~/.prompt ]; then
    mkdir ~/.prompt
  fi
  prompt_root=~/.prompt/$(basename $(git rev-parse --show-toplevel))
  if ! [ -f $prompt_root/current_env.txt ]; then
      touch $prompt_root/current_env.txt
    fi
  if ! [ -f $prompt_root/new_env.txt ]; then
    touch $prompt_root/new_env.txt
  fi
  git status --short > $prompt_root/new_env.txt
  git describe --abbrev=12 --always --dirty=+ >> $prompt_root/new_env.txt
  if ! cmp --silent $prompt_root/current_env.txt $prompt_root/new_env.txt; then
    cp $prompt_root/new_env.txt $prompt_root/current_env.txt
    return 1
  fi
}

minprompt() {
  prompt_root=~/.prompt/$(basename $(git rev-parse --show-toplevel))

  if [ ! -d ~/.prompt ]; then
    mkdir ~/.prompt
  fi
  if [ ! -d $prompt_root ]; then
    mkdir $prompt_root
  fi
  if ! [ -f $prompt_root/vcs_prompt.txt ]; then
    touch $prompt_root/vcs_prompt.txt
  fi

  if ! echo "$PWD" | grep -oh "$HOME" &> /dev/null || [[ ! "$PWD" = "$HOME" && "$(git rev-parse --show-toplevel)" = "$HOME" ]]; then
    PROMPT="%{$fg[green]%}%(4~|.../%8~|%~)"$'\n'"%{$fg[default]%}%# "
  elif checkgitenv; then
    PROMPT="$(cat $prompt_root/vcs_prompt.txt) %{$fg[green]%}%(4~|.../%8~|%~)"$'\n'"%{$fg[default]%}%# "
  else
    changes=$(git status --short | wc -l | xargs)
    if [ $changes -gt 0 ]; then
      if ! [ "$(git status --short | tail -n 1 | head -c 2)" = "??" ]; then
        changes="$fg[yellow]$changes "
      else
        changes="$fg[red]$changes "
      fi
    else
      changes=""
    fi
    percent='%%'
    branch_name="$(git branch --show-current)"
    if ! [ -z $branch_name ]; then
      branch_name="$branch_name"
    fi
   commit_msg="$(git log -1 --pretty=%B | head -n 1)"
   vcs_prompt="$changes$fg[magenta]$branch_name $fg[blue]$commit_msg" 
   echo "$vcs_prompt" > $prompt_root/vcs_prompt.txt
   NEWLINE=$'\n'
   PROMPT="$(cat ${prompt_root}/vcs_prompt.txt) $fg[green]%~${NEWLINE}$fg[default]%# "
  fi
}

