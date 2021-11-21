#!/bin/bash

# - Проверка подключения к сети
# printf "•Check network connection:\n"
# ping -c 3 archlinux.org | grep "bytes from"

# Включение и настройка ssh, пароль для root'а
pc_ip=$(networkctl status eth0 | grep --before-context=3 -T "Gateway: "|grep "Address")
printf "\n•Enable and setup SSH\n"
echo $pc_ip
sudo systemctl enable sshd
sudo systemctl start sshd
printf "\n Login: root\n Set password.\n"
sudo passwd root

# Разметка диска
printf "\nСейчас необходимо провести разметку диска, создав на нём таблицу gpt и три раздела.\n 1. Boot - 1 Gb (type EFI)\n 2. Swap - по объёму RAM 4/8/16 (type linux swap)\n 3. Корневой / - всё остальное (type linux filesystem)\nНе забудьте в конце прожать wrie для записи измненений.\nДля продолжения нажмите любую кнопку."
read
sudo cfdisk

# - Получаем список разделов
source ~/functions.sh
get_partitions=( $(sudo ls /dev/sd* | grep "sd...*") )

# - Выводим список разделов
printf "\n•Well, now we have %c partitions.\n" ${#get_partitions[@]}
sudo fdisk -l | grep "/dev/sd"

# - Выбираем разделы для мониторвания
while [ -z ${map_boot+x} ]; do
	list=${get_partitions[@]}
	
	printf "\n•Which one you want to map as boot?\n"
	options=($list)
	select_option "${options[@]}"
	map_boot=$?
	list=${list[@]/${options[$map_boot]}}
	printf "%s selected as boot partition" ${options[$map_boot]}
	map_boot=${options[$map_boot]}
	
	printf "\n\n•Which one you want to map as swap?\n"
	options=($list)
	select_option "${options[@]}"
	map_swap=$?
	list=${list[@]/${options[$map_swap]}}
	printf "%s selected as swap partition" ${options[$map_swap]}
	map_swap=${options[$map_swap]}

	printf "\n\n•And as for root directory?\n"
	options=($list)
	select_option "${options[@]}"
	map_root=$?
	list=${listp[@]/${options[$map_root]}}
	printf "%s selected as swap partition" ${options[$map_root]}
	map_root=${options[$map_root]}
done

# Промежуточный итог 
printf "\n\n•Well, finally we use:\n - %s as boot\n - %s as swap\n - %s as root\n" $map_boot $map_swap $map_root 

# Форматирование разделов и подключение свапа
mkfs.fat -F32 $map_boot
mkswap $map_swap
swapon $map_swap
mkfs.btrfs $map_root

# Монтирование диска и установка системы
pacman -Syy
mount $map_root /mnt
pacstrap /mnt base linux linux-firmware sudo micro nano openssh

# Создание fstab'а
genfstab -U /mnt >> /mnt/etc/fstab

# Подключаемся в образ системы
arch-chroot /mnt