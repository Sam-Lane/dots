export EDITOR=nvim
zmodload zsh/zprof

# on MacOS set this and restart system for better keyboard performance :^)
# defaults write NSGlobalDomain KeyRepeat -int 1

autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dracula"

plugins=(git)

source $ZSH/oh-my-zsh.sh


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

alias dicker="docker"
alias doco="docker compose"

#I keep making this mistake
alias "git pish"="git push"

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

