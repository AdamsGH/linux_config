alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias cat='bat'
alias du='dust'
alias df='duf'
alias ps='procss'
alias dig='dog'

alias pc='sudo pacman'
alias pci='sudo pacman -S --noconfirm'
alias mc='micro'
alias lzd='sudo lazydocker'
alias backup_vw='sudo sqlite3 /root/docker/vw-data/db.sqlite3 ".backup '/home/adams/backup/db-$(date '+%Y%m%d-%H%M').sqlite3'"'

# Transmission
tr_download='transmission-cli --download-dir'
tr_conf='micro /var/lib/transmission/.config/transmission-daemon/settings.json'
