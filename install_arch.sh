#!/bin/bash

# Функция для выбора путей монтирования 
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

# - Проверка подключения к сети
printf "•Check network connection:\n"
ping -c 3 archlinux.org | grep "bytes from"

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
# source ~/functions.sh
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

# Network
cp /etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network
echo "nameserver 8.8.8.8" >> /mnt/etc/resolv.conf

curl https://raw.githubusercontent.com/AdamsGH/linux_config/main/inside_chroot.sh --output /mnt/inside.sh
chmod u+x /mnt/inside.sh

# Подключаемся в образ системы
arch-chroot /mnt /inside.sh