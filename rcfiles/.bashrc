HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize
HISTSIZE=9999
HISTFUSESIZE=9999
HISTTIMEFORMAT="%Y%m%d %T  "
IFCONFIG=$(which ifconfig)
ROUTE="$(which route)"
NIC=$($ROUTE | grep ^default | awk '{print $NF}')
IP="$($IFCONFIG "$NIC" | grep "inet " | awk '{print $2}' | tr -d "adr:")"
alias ls='ls -hF --color=tty'
alias myip='echo $IP'
alias screen='screen -U'
alias uc='ssh stack@undercloud-0'
export EDITOR=vim

# LOCALES
export LANG="en_US.UTF-8"
export LC_COLLATE="C"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"

export TMP=/tmp
export TEMP=${TMP}

PS1='[$(date +%T)][\u@$IP:$(pwd)] # '
cd "$HOME"
