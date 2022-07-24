#!/bin/zsh

###############################
# EXPORT ENVIRONMENT VARIABLE #
###############################

# edior
export EDITOR=/usr/bin/micro
export VISUAL=/usr/bin/micro

# zsh
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"   # History filepath
export HISTSIZE=7500                   # Maximum events for internal history
export SAVEHIST=75000                   # Maximum events in history file
