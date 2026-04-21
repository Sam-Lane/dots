export EDITOR=nvim
export DEFAULT_USER=slane
zmodload zsh/zprof

eval $(/opt/homebrew/bin/brew shellenv)

# on MacOS set this and restart system for better keyboard performance :^)
# defaults write NSGlobalDomain KeyRepeat -int 1

autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

# export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="dracula"


# plugins=(git pipenv)

# source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"
bindkey -e
zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  expand-or-complete-with-dots() {
    # use $COMPLETION_WAITING_DOTS either as toggle or as the sequence to show
    [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f"
    # turn off line wrapping and print prompt-expanded "dot" sequence
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  # Set the function as the default tab completion widget
  bindkey -M emacs "^I" expand-or-complete-with-dots
  bindkey -M viins "^I" expand-or-complete-with-dots
  bindkey -M vicmd "^I" expand-or-complete-with-dots
fi

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit


alias ls="ls --color=auto"

#neo vim
alias vim="nvim"
alias vi="nvim"
#stop me from being naughty boy

alias ansible-playbook="ansible-playbook --diff"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"


# Kubernetes alias

function kubectl() {
	if ! type __start_kubectl >/dev/null 2>&1; then
		source <(command kubectl completion zsh)
	fi

	command kubectl "$@"
}

alias k="kubectl"
alias kwatch="watch kubectl"
alias kns="kubectl config set-context --current --namespace"
alias kluster="kubectl config use-context "
alias k9s="k9s --logoless"

alias dicker="docker"
alias doco="docker compose"

#I keep making this mistake
alias "git pish"="git push"
alias "lg"="lazygit"

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# git push and skip CI
alias "gpnoci"="git push -o ci.skip"

gimmy(){
	BRANCH="${1:-main}"
	git stash
	git pull && git checkout $BRANCH && git pull && git checkout - && git merge $BRANCH
	git stash pop
}

gbranch(){
	MAIN_BRANCH="${2:-main}"
	echo "new branch $1 from $MAIN_BRANCH"
	git checkout $MAIN_BRANCH && git pull && git checkout -b $1
}

gippy(){
	echo git add . && git commit -m "$1" && git push
	git add . && git commit -m "$1" && git push
}

# containme drops you and your current path into a docker image you spesify
containme(){
	echo 📦 dropping into a $1 container with $PWD mounted into it
	docker run -it --rm -v $(pwd):/work -w /work $1 $2
}


urlencode(){
  local args="$@"
  jq -nr --arg v "$args" '$v|@uri';
}

# duckduckgo search from the command line
duck(){
        echo 🦆💨 quack 🔎 $@
        open "https://duckduckgo.com/html/?q=$(urlencode "$@")"
}

# gifmov takes a MacOS screen recording from command shift 5 and converts it to a gif.
gifmov(){
        ffmpeg -i $1 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > $2
}

# grab current ip address
giefip(){
	echo "curl http://checkip.amazonaws.com"
	curl http://checkip.amazonaws.com
}

randomstr() {
	size="${1:-32}"
	head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c$size
}

set_env() {
	# set_env reads a .env file ignores comments
	# and sets the values to the environment
	export $(grep -v '^#' .env | xargs)
}

unset_env() {
	# set_env reads a .env file ignores comments
	# and unsets the values to the environment
	unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
}

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"


# # STOP SOURCNG AUTOMATICALLY
# conda config --set auto_activate_base false

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/slane/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/slane/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/Users/slane/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/slane/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


# Created by `pipx` on 2024-09-17 07:40:33
export PATH="$PATH:/Users/slane/.local/bin"

# Added by GDK bootstrap
eval "$(/opt/homebrew/bin/mise activate zsh)"

[[ -s "/Users/slane/.gvm/scripts/gvm" ]] && source "/Users/slane/.gvm/scripts/gvm"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# opencode
export PATH=/Users/slane/.opencode/bin:$PATH

# k8s helpers
[[ -f "$HOME/.local/bin/helpers.sh" ]] && source "$HOME/.local/bin/helpers.sh"
