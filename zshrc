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
alias code="nvim"

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
alias kcluster="kubectl config use-context "

alias doco="docker compose"

containme(){
	echo 📦 dropping into a $1 container with $PWD mounted into it
	docker run -it --rm -v $(pwd):/work -w /work $1 $2
}


urlencode(){
  local args="$@"
  jq -nr --arg v "$args" '$v|@uri';
}

duck(){
        echo 🦆💨 quack 🔎 $@
        open "https://duckduckgo.com/html/?q=$(urlencode "$@")"
}

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
