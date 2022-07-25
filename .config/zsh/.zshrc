# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$ZDOTDIR/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$ZDOTDIR/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -e
zstyle :compinstall filename '$XDG_CONFIG_HOME/.zshrc'
autoload -Uz compinit
compinit

# Shell profile & autosuggestions
source $XDG_CONFIG_HOME/powerlevel10k/powerlevel10k.zsh-theme
source $XDG_CONFIG_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $XDG_CONFIG_HOME/.p10k.zsh ]] || source $XDG_CONFIG_HOME/.p10k.zsh

# Alias
source $XDG_CONFIG_HOME/.alias
