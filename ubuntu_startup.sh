#!/bin/bash

apt-get	update && apt-get upgrade -y
apt install wireguard micro bat zsh -y

shell_conf=/etc/shellcfg
mkdir -p $shell_conf

curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.zshenv > $shell_conf/.zshenv
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.zshrc > $shell_conf/.zshrc

mkdir -p $shell_conf/.config
echo "alias cat='batcat'" >> $shell_conf/.config/.alias
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.p10k.zsh > $shell_conf/.config/.p10k.zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $shell_conf/.config/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions $shell_conf/.config/zsh-autosuggestions

echo "export shell_conf=$shell_conf
source $shell_conf/.zshenv" > ~/.zshenv

chmod -R 777 $shell_conf
chsh --shell /bin/zsh $USER