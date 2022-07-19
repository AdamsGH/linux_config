apt-get	update && apt-get upgrade -y
apt install wireguard micro bat zsh -y

echo "export shell_conf=/etc/shellcfg
source $shell_conf/.zshenv" >> ~/.zshenv

curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.zshenv > $shell_conf/.zshenv
mkdir -p $shell_conf/.config
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.zshrc > $shell_conf/.config/.zshrc
echo "alias cat='batcat'" >> $shell_conf/.config/.alias
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.p10k.zsh > $shell_conf/.config/.p10k.zsh
chsh --shell /bin/zsh $USER
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $shell_conf/.config/powerlevel10k
