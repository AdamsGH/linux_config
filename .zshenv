#!/bin/zsh

###############################
# EXPORT ENVIRONMENT VARIABLE #
###############################

# edior
export EDITOR=/usr/bin/micro
export VISUAL=/usr/bin/micro

# zsh
export ZDOTDIR="/etc/shellcfg"
export XDG_CONFIG_HOME="$ZDOTDIR/.config"
export HISTFILE="$HOME/.zhistory"   # History filepath
export HISTSIZE=7500                   # Maximum events for internal history
export SAVEHIST=75000                   # Maximum events in history file
