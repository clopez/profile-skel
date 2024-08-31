# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# from bash(1) "If HISTFILESIZE is not set, no truncation is performed."
unset HISTFILESIZE

# from bash(1):
# The value of the HISTSIZE variable is used as the number of commands  to  save in
# a history  list.  The text of the last HISTSIZE commands (default 500) is saved.
#
# from my_experience(™):
# Not setting the variable HISTSIZE makes it to only read only last 500 values.
# But setting it to an empty value makes it to read the full history.
# This behaviour seems not to be documented but works (as far as I tested)
export HISTSIZE
export HISTTIMEFORMAT="%F %T "

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1='\[\033[02;36m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    fi
    # we love colors!
    alias ls='ls --color=always'
    alias dir='dir --color=always'
    alias vdir='vdir --color=always'
    alias grep='grep --colour=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
    alias pico='nano -Y sh'
    alias grey-grep="GREP_COLOR='1;30' stdbuf -oL grep --color=always"
    alias red-grep="GREP_COLOR='1;31' stdbuf -oL grep --color=always"
    alias green-grep="GREP_COLOR='1;32' stdbuf -oL grep --color=always"
    alias yellow-grep="GREP_COLOR='1;33' stdbuf -oL grep --color=always"
    alias blue-grep="GREP_COLOR='1;34' stdbuf -oL grep --color=always"
    alias magenta-grep="GREP_COLOR='1;35' stdbuf -oL grep --color=always"
    alias cyan-grep="GREP_COLOR='1;36' stdbuf -oL grep --color=always"
    alias white-grep="GREP_COLOR='1;37' stdbuf -oL grep --color=always"
    # http://unix.stackexchange.com/questions/366/convince-grep-to-output-all-lines-not-just-those-with-matches
    highlight() { stdbuf -oL grep --color=always -P "${@}|$"; }
    # Set color for files
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    fi


else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1='\u@\h \W \$ '
    else
        PS1='\u@\h \w \$ '
    fi
fi
[ "${TERM}" = linux ] && echo -ne "\033[?8c"
# Change XTerm window title for terminals supporting that feature
#
case ${TERM} in
    xterm-* | xterm | screen)
        PS1="\[\033]0;\u@\h:\w\007\]$PS1"
        ;;
esac

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lss="ls --sort=size -r1 -sh"
alias lst="ls --sort=time -r1 -sh"
alias lcut='cut -c1-$COLUMNS'

# some other useful alias and functions
alias nocolor="perl -pe 's/\e\[?.*?[\@-~]//g'"

waitpid() {
	local retcode=1
	while ps "$1" &>/dev/null; do sleep 1; retcode=0; done
	return ${retcode}
}
git_last_branches() {
	git reflog | grep -Po "moving\ from\ [^\ ]+" | sed "s/moving\ from\ //g" | awk '!x[$0]++'
}



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
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# git
git_get_branch_name ()
{
    local branch=$(git symbolic-ref HEAD 2> /dev/null \
        | sed 's#refs\/heads\/\(.*\)#\1#')
    [ "$branch" ] && echo "$branch "
}

# PS1
if [ -f ~/.bashps1 ]; then
    . ~/.bashps1
else
    if [[ -x /usr/bin/git ]] ; then
        [[ $PS1 = *git_get_branch_name* ]] \
            || export PS1="\[\e[1;32m\]\$(git_get_branch_name)\[\e[0;0m\]$PS1"
    fi

    if [[ -n "${CROSS_COMPILE}" ]]; then
        export PS1="\[\e[1;33m\](cross) \[\e[0;0m\]${PS1}"
    fi
fi
