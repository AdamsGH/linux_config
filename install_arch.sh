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

# Устанавливаем время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Локаль
printf "\n•Установка локализации.\nСнять комментарии с следующих строк:\n en_US.UTF-8\n ru_RU.UTF-8\n"
read 
micro /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Задать имя ПК
printf "\n•Введите имя ПК: \n"
read pc_hostname
echo $pc_hostname > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" > /etc/hosts
echo "127.0.1.1 "$pc_hostname > /etc/hosts
cp /etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Пароль рута
printf "\n•Введите пароль суперпользователя: \n"
passwd

# Загрузчик 
pacman -S grub efibootmgr mtools
mkdir /boot/efi
mount $map_boot /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi
grub-mkconfig -o /boot/grub/grub.cfg
