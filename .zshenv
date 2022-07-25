#!/bin/zsh

###############################
# EXPORT ENVIRONMENT VARIABLE #
###############################

# edior
export EDITOR=/usr/bin/micro
export VISUAL=/usr/bin/micro

# zsh
export XDG_CONFIG_HOME="$shell_conf/.config"
export ZDOTDIR="$shell_conf"
export HISTFILE="$ZDOTDIR/.zhistory"   # History filepath
export HISTSIZE=7500                   # Maximum events for internal history
export SAVEHIST=75000                   # Maximum events in history file
