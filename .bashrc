# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILE=$HOME/.bash_history
export HISTSIZE=10000000000
export HISTFILESIZE=2000000000
#export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]> '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias r='rails'
alias g='git'
alias be='bundle exec'
alias migrate='rails db:migrate && rails db:test:prepare'
alias rollback='rails db:rollback && RAILS_ENV=test rails db:rollback'
alias redo='rails db:migrate:redo && RAILS_ENV=test rails db:migrate:redo'
alias hpr='hub pull-request'
alias sic='sudo snap install --classic'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#alias dk='docker-compose -f ~/src/pico-docker/docker-compose.yml'
alias dkreup='dk up -d --force-recreate --no-deps'
alias dkrebuild='dk build --pull --no-cache'
alias dkvreup='dk rm -fsv $1 && dk build --no-cache $1 && dk up --force-recreate --no-deps -d $1'

alias epoch="date +%s"
alias ymd="date +%Y-%m-%d"
alias dkreseed='dk up seeding && dk restart mes'
alias dockerips='docker ps | cut -f1 -d" " | tail -n+2 | while read container; do docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}	{{.Name}}" $container; done'
alias dc='docker-compose'
alias dkrepg='dk stop postgres && dk rm postgres && docker volume rm pico-docker_postgresdata && dk up -d --force-recreate --no-deps postgres'
alias dkredbt='dk up mes-migrations mes-migrations-test; until dk run --rm dbt dbt run --full-refresh; do sleep 1; done && until dk run --rm dbt-test dbt run --full-refresh; do sleep 1; done && dk restart data-api data-api-test'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
  elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/bin:$PATH"

export EDITOR=nvim

export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

export PATH="$HOME/.local/bin:$PATH"
#export PATH="$HOME/.nvm/versions/node/v7.8.0/bin:$PATH"


#if [[ ! $TERM =~ screen ]]; then
  #exec mux default
#fi

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#trap 'echo "DONE"' 0
  #nvm use stable &
#wait

# locate / updatedb config from http://askubuntu.com/a/93477/40590
export LOCATE_PATH="$HOME/var/mlocate.db"
# updatedb -l 0 -o $HOME/var/mlocate.db -U $HOME

[ -s "~/bin/hub.bash_completion.sh" ] && source ~/bin/hub.bash_completion.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

export NO_AT_BRIDGE=1 # http://unix.stackexchange.com/questions/230238/starting-x-applications-from-the-terminal-and-the-warnings-that-follow
export WLR_NO_HARDWARE_CURSORS=1

export TERMINFO=~/.terminfo

export R_HISTFILE="$HOME/.Rhistory"

export DOCKER_CLIENT_TIMEOUT=120

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/go/bin:$PATH"

#export PATH="/usr/local/opt/qt/bin:$PATH"
#export PATH="/usr/local/opt/mysql-client/bin:$PATH"
#export PATH="$(npm bin):$PATH"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"


export GOROOT="/usr/local/go"
export GO111MOD="on"
export PATH="$GOROOT/bin:$PATH"

#export PATH="$PATH:$GOPATH/bin"
export GOOGLE_APPLICATION_CREDENTIALS="/home/hoffmanc/src/picomes/backups/pico-mes-60611504bf8d-hoffmanc-test-backup.json"

export CLOUDSDK_PYTHON=/usr/bin/python2

if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t picomes || tmux new-session -s picomes
fi

. ~/.bin/z.sh
source /usr/share/nvm/init-nvm.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/hoffmanc/Downloads/gcp/google-cloud-sdk/path.bash.inc' ]; then . '/home/hoffmanc/Downloads/gcp/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/hoffmanc/Downloads/gcp/google-cloud-sdk/completion.bash.inc' ]; then . '/home/hoffmanc/Downloads/gcp/google-cloud-sdk/completion.bash.inc'; fi
