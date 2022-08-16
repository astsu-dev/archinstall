USER="astsu"
HOSTNAME="arch"
# First locale will be default system language
LOCALES=("en_US.UTF-8 UTF-8" "ru_RU.UTF-8 UTF-8" "uk_UA.UTF-8 UTF-8")
EFI_DIRECTORY=/boot/efi

read -s -p "root password: " root_password
echo
read -s -p "$USER password: " regular_password
echo

# Set time zone
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

hwclock --systohc

# Generate locales
for locale in ${LOCALES[@]}; do
    sed -i "s/#$locale/$locale/" /etc/locale.gen
done
locale-gen
echo "LANG=${LOCALES[0]}" > /etc/locale.conf

# Set hostname
echo $HOSTNAME > /etc/hostname

# Hosts
echo -e "127.0.0.1 localhost\n::1       localhost\n127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" > /etc/hosts

# Root password
echo $root_password | passwd

# Create regular user
useradd -m -G wheel,audio,video,storage $USER
echo $regular_password | passwd $USER

# Install packages
pacman -Syu
pacman -S sudo grub efibootmgr os-prober networkmanager

# Enable network
systemctl enable NetworkManager

# Allow wheel group to execute any command
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# Setup bootloader
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=$EFI_DIRECTORY --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
