# Arch Installation

## Verify boot mode
```sh
ls /sys/firmware/efi/efivars
```

If the command shows the directory without error, then the system is booted in UEFI mode. The system must be booted in UEFI mode.

## Connect to the internet

Check connection:

```sh
ping archlinux.org
```

You can connect to Wi-Fi using `iwctl`:

Run `iwctl`:

```sh
iwctl
```

First, if you do not know your wireless device name, list all Wi-Fi devices:

```sh
device list
```

Then, to initiate a scan for networks (note that this command will not output anything):

```iwctl
station <device> scan
```

You can then list all available networks:

```iwctl
station device get-networks
```

Finally, to connect to a network:

```iwctl
station <device> connect <SSID>
```

## Update the system clock

Use timedatectl to ensure the system clock is accurate:

```sh
timedatectl set-ntp true
```

To check the service status, use:

```sh
timedatectl status
```

## Partition the disks

You need to install Arch Linux after Windows.

Show the available partitions:

```sh
lsblk
```

Use `cfdisk` to modify partition table:

```sh
cfdisk
```

- Create EFI partition (At least 300 MB, EFI type) if you don't have it yet. If you install Arch after Windows you already have the EFI partition.
- Create root partition (Linux filesystem type)
- Create swap partition (Linux swap type)

## Format partitions

Format root partition:

```sh
mkfs.ext4 /dev/root_partition
```

If you created a partition for swap, initialize it with `mkswap`:

```sh
mkswap /dev/swap_partition
```

If you created an EFI system partition, format it to FAT32 using `mkfs.fat`. **DON'T** format it if you have already created the EFI partition.

```sh
mkfs.fat -F 32 /dev/efi_system_partition
```

## Mount the file systems

Mount the root volume to /mnt:

```sh
mount /dev/root_partition /mnt
```

Mount the EFI system partition:

```sh
mount --mkdir /dev/efi_system_partition /mnt/efi
```

If you created a swap volume, enable it with swapon:

```sh
swapon /dev/swap_partition
```

## Install essential packages

For AMD processors:

```sh
pacstrap /mnt base base-devel linux linux-firmware amd-ucode vim networkmanager
```

For Intel processors:

```sh
pacstrap /mnt base base-devel linux linux-firmware intel-ucode vim networkmanager
```

## Generate fstab

Generate an fstab file (use -U or -L to define by UUID or labels, respectively):

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

Check the resulting /mnt/etc/fstab file, and edit it in case of errors.

## Chroot

Change root into the new system:

```sh
arch-chroot /mnt
```

## Install

Run install script:

```sh
chmod +x base.sh
./base.sh
```

Exit from system:

```sh
exit
```

Unmount partitions:

```sh
umount -R /mnt
```

Reboot:

```sh
reboot
```
