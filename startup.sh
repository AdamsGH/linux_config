#!/bin/bash

# Обновление Pacman
echo "---Pacman update---"
sudo pacman -Syu --noconfirm

# Установка yay
echo "---Install yay---"
sudo pacman -S --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# Установка стандартного набора
echo "---Install default software---"
for software_list in openssh git zsh lsd bat dust duf procs dog fd gtop curlie micro screen tldr
	do
		sudo pacman -S --noconfirm $software_list
	done

# Установка Docker'а и сопутствующих
echo "---Install Docker---"
sudo pacman -S --noconfirm docker docker-compose

# Дополнения и настройка для ZSH
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.zshenv > ~/.zshenv
mkdir -p  ~/.config/zsh
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.zshrc > ~/.config/zsh/.zshrc
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.alias.zsh > ~/.config/zsh/.alias.zsh
curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/.config/zsh/.p10k.zsh > ~/.config/zsh/.p10k.zsh
chsh --shell /bin/zsh $USER
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/zsh/powerlevel10k
