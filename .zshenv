# Environment Variables
export cb="$HOME/.config/bin"
export ct="$HOME/.config/tip"
export cs="$HOME/.config/sample"
export ck="$HOME/.config/kit"

export pr="$HOME/pile/repos"

# Configuration
autoload -U colors && colors


set -o vi
setopt autocd
autoload -Uz predict-on
zle -N predict-on
bindkey '^N' end-of-line
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

spin-key() spin refresh
zle -N spin-key 
bindkey '^E' spin-key

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
path+="$HOME/.config/bin"
export PATH

# Utilities
mkcd() {
   mkdir $1
   cd $1
}

checkgitenv() {
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
  prompt_root=~/.config/.prompt/$(basename $(git rev-parse --show-toplevel))

  if [ ! -d $prompt_root ]; then
    mkdir -p $prompt_root
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
    branch_name="$(git rev-parse --abbrev-ref HEAD)"
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

if command -v bat &>/dev/null; then
  export FZF_DEFAULT_OPTS="-e --scheme=path --cycle --info=inline --preview='bat --color=always --style=numbers --line-range=:500 {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
else
  export FZF_DEFAULT_OPTS="-e --scheme=path --cycle --info=inline --preview='batcat --color=always --style=numbers --line-range=:500 {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
fi

if [ "$(uname)" != "Darwin" ]; then 
  alias -g bat=batcat
fi
