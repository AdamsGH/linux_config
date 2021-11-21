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
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi
grub-mkconfig -o /boot/grub/grub.cfg
