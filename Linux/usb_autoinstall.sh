#/usr/bin/env bash
# TODO: test using a personal computer
#### HEADER ####
# Script to generate pendrive to install Debian using preseed
# with no interaction with user.
# Based on: 
# +https://gist.github.com/ageekymonk/3d691d89c14da837955c
# +https://www.debian.org/releases/stable/example-preseed.txt
# @author: Adriano J. Holanda
################
USER="rar"
USER_FULLNAME="Rafael A. Rosales"
DOMAIN="dcm.ffclrp.usp.br"
RELEASE="bullseye"
echo "Custom USB Debian Installer with preseed"
disk=$1
iso=$2
primary="$disk"1
if [ -z $disk ]
then
echo "Specify a correct drive name"
exit
fi

if [ -z $iso ]
then
echo "Specify a correct iso file"
exit
fi

echo "Wiping out all the contents of the USB drive"
#dd if=/dev/zero of=$disk bs=10M

echo "Creating a Primary Partition"
(echo n; echo p; echo 1; echo ; echo ; echo w) | fdisk $disk

echo "Creating a Filesystem"
mkfs.ext2 $primary

mkdir /mnt/usb
mount  $primary /mnt/usb
grub-install --root-directory=/mnt/usb $disk

echo "Download the initrd image"
mkdir /mnt/usb/hdmedia-${RELEASE}
wget http://ftp.debian.org/debian/dists/${RELEASE}/main/installer-amd64/current/images/hd-media/vmlinuz -O /mnt/usb/hdmedia-wheezy/vmlinuz
wget http://ftp.debian.org/debian/dists/${RELEASE}/main/installer-amd64/current/images/hd-media/initrd.gz -O /mnt/usb/hdmedia-wheezy/initrd.gz
mkdir /mnt/usb/isos

cp $iso /mnt/usb/isos/

echo "Write to grub file"
cat << EOF > /mnt/usb/boot/grub/grub.cfg
# This is to define colors in the grub menu
#set color_normal='green/black'
#set color_highlight='light-green/black'

# Define some paths
# The / is the root of the installation media (/dev/sdb1)
set isosdir='/isos'
set hdmediawheezy='/hdmedia-wheezy'

# Below is where the running debian installer will find the preseed file
# Debian installer provided with hd-media images mounts the installation media filesystem
# under /hd-media
set preseed='/hd-media/preseed'

# Manual entry
menuentry 'Debian 7.4 amd64 manual install' {
    linux \$hdmediawheezy/vmlinuz iso-scan/filename=\$isodir/debian-7.4.0-amd64-netinst.iso priority=critical
    initrd \$hdmediawheezy/initrd.gz
}

# Automated entry
menuentry 'Debian 6.0 amd64 automatic install' {
    linux \$hdmediawheezy/vmlinuz iso-scan/filename=\$isodir/debian-7.4.0-amd64-netinst.iso preseed/file=\$preseed/standard-wheezy.preseed auto=true priority=critical
    initrd \$hdmediawheezy/initrd.gz
}
EOF

mkdir /mnt/usb/preseed
cat << EOF > /mnt/usb/preseed/standard-${RELEASE}.preseed

###############################################################################
# General
###############################################################################

# This should ensure that only 'critical' questions are asked
d-i debconf/priority string critical

# Automatically download and install updates
unattended-upgrades unattended-upgrades/enable_auto_updates boolean true

# Don't prompt for firmware
d-i hw-detect/load_firmware boolean true

###############################################################################
# Network
###############################################################################
# hostname and domain are taken from DHCP server that has precedence over the
# values set here. We need to set the values to allow the use of functions
# get_hostname and get_domain.
d-i netcfg/enable boolean true
d-i netcfg/choose_interface select auto
d-i netcfg/disable_dhcp boolean false
d-i netcfg/get_hostname string ${USER}
d-i netcfg/get_domain string ${DOMAIN}

# We don't need network as all stuff is contained in the USB flash drive
d-i netcfg/enable boolean false
d-i netcfg/wireless_wep string

###############################################################################
# Localization/Timezone
###############################################################################
#### Locale ####
d-i debian-installer/locale string pt_BR.UTF-8
d-i debian-installer/keymap select br
d-i localechooser/supported-locales multiselect en_US.UTF8
d-i localechooser/translation/warn-light boolean true
d-i localechooser/translation/warn-severe boolean true

#### Timezone ####
d-i time/zone select America/Sao_Paulo
d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true

#### Console ####
d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string br

###############################################################################
# Keyboard
###############################################################################
d-i keyboard-configuration/xkb-keymap select br

###############################################################################
# Partitioning
###############################################################################
# We assume the target computer has only one harddrive.
# In most case the USB Flash drive is attached on /dev/sda
# but sometimes the harddrive is detected before the USB flash drive and
# it is attached on /dev/sda and the USB flash drive on /dev/sdb
# You can set manually partman-auto/disk and grub-installer/bootdev or
# used the early_command option to automatically set the device to use.
d-i partman/early_command string \
   USBDEV=\$(mount | grep hd-media | cut -d" " -f1 | sed "s/\(.*\)./\1/");\
   BOOTDEV=\$(list-devices disk | grep -v \$USBDEV | head -1);\
   debconf-set partman-auto/disk \$BOOTDEV;\
   debconf-set grub-installer/bootdev \$BOOTDEV;
#d-i partman-auto/disk string /dev/sdb$
#d-i grub-installer/bootdev  string /dev/sdb
d-i grub-installer/only_debian boolean false
d-i grub-installer/with_other_os boolean false

# Here we set the partition layout using a predefined recipe (atomic)
# Refer to preseed documentation to create custom recipes
# Alternatively, you may specify a disk to partition. If the system has only
# one disk the installer will default to using that, but otherwise the device
# name must be given in traditional, non-devfs format (so e.g. /dev/sda
# and not e.g. /dev/discs/disc0/disc).
# For example, to use the first SCSI/SATA hard disk:
#d-i partman-auto/disk string /dev/sda
# In addition, you'll need to specify the method to use.
# The presently available methods are:
# - regular: use the usual partition types for your architecture
# - lvm:     use LVM to partition the disk
# - crypto:  use LVM within an encrypted partition
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
# Uncomment the line below to preseed the disk layout confirmation
#d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/mount_style select uuid

## Partitioning for EFI
# If your system needs an EFI partition you could add something like
# this as the first element in the recipe.
# This recipe creates a small /boot partition, suitable
# swap, and uses the rest of the space for the root/home partitions:
d-i partman-auto/expert_recipe string                         \
      boot-root-home ::                                            \
               538 538 1075 free                              \
                      $iflabel{ gpt }                         \
                      $reusemethod{ }                         \
                      method{ efi }                           \
                      format{ }                               \
               .                                              \
              1024 3072 2048 ext4                             \
                      $primary{ } $bootable{ }                \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ /boot }                     \
              .                                               \
              80000 1000000 1000000000 ext4                   \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ / }                         \
              .                                               \
              1024 2048 300% linux-swap                       \
                      method{ swap } format{ }                \
              .                                               \
              75000 100000 200000 ext4                        \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ /home }                     \
              .

###############################################################################
# User creation
###############################################################################
# Skip creation of a root account (normal user account will be able to use sudo).
# run 'mkpasswd -m sha-512' to generate password
d-i passwd/root-login boolean true
d-i passwd/root-password-crypted password $6$wzSPKbDwl0GrN8pd$SyD4SkScp4.AXiU2VaUWKzBGmMUbaqbNNxFppJ9P07Bew02oddEGp6tu9jY9QP2eCk0LDBryDeL2wES3DxilM.

d-i passwd/username string ${USER}
d-i passwd/user-fullname string ${USER_FULLNAME}
d-i passwd/root-password password backinblack
d-i passwd/root-password-again password backinblack

d-i passwd/user-default-groups string audio backup cdrom dip floppy lp plugdev mail netdev users video sudo
###############################################################################
# Package selection
###############################################################################
# PROFILES: standard, desktop, gnome-desktop, xfce-desktop, kde-desktop,
# cinnamon-desktop, mate-desktop, lxde-desktop, web-server, print-server
# ssh-server
d-i base-installer/kernel/override-image string linux-generic
tasksel tasksel/first multiselect ssh-server, standard, gnome-desktop

# Extras: individual additional packages to install
d-i pkgsel/include string  git net-tools openssh-server python3 sudo vim
d-i pkgsel/exclude string  nano vim-tiny

# Policy for applying updates. May be "none" (no automatic updates),
# "unattended-upgrades" (install security updates automatically), or
# "landscape" (manage system with Landscape).
d-i pkgsel/update-policy select unattended-upgrades

###############################################################################
# Additional packages
###############################################################################
d-i pkgsel/install-language-support boolean true

###############################################################################
# Mirror
###############################################################################
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.br.debian.org
d-i mirror/http/directory string /debian
d-i mirror/suite string ${RELEASE}
d-i mirror/http/proxy string

###############################################################################
# GRUB
###############################################################################
# Grub is the boot loader (for x86).
#d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string /dev/sda

# Opt out of this
d-i popularity-contest/participate boolean false

###############################################################################
# Post installation
###############################################################################
#d-i preseed/late_command string COMMAND

###############################################################################
# Reboot
###############################################################################
# Once installation is complete, automatically power off.
d-i finish-install/reboot_in_progress note

# Uncomment to power off the machine instead of reboot
#d-i debian-installer/exit/poweroff boolean true

# We assume the target computer has only one harddrive.
# In most case the USB Flash drive is attached on /dev/sda
# but sometimes the harddrive is detected before the USB flash drive and
# it is attached on /dev/sda and the USB flash drive on /dev/sdb
# You can set manually partman-auto/disk and grub-installer/bootdev or
# used the early_command option to automatically set the device to use.
d-i partman/early_command string \
   USBDEV=\$(mount | grep hd-media | cut -d" " -f1 | sed "s/\(.*\)./\1/");\
   BOOTDEV=\$(list-devices disk | grep -v \$USBDEV | head -1);\
   debconf-set partman-auto/disk \$BOOTDEV;\
   debconf-set grub-installer/bootdev \$BOOTDEV;
#d-i partman-auto/disk string /dev/sdb$
#d-i grub-installer/bootdev  string /dev/sdb
d-i grub-installer/only_debian boolean false
d-i grub-installer/with_other_os boolean false

# Here we set the partition layout using a predefined recipe (atomic)
# Refer to preseed documentation to create custom recipes
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
# Uncomment the line below to preseed the disk layout confirmation
#d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/mount_style select uuid

# We don't want use a remote mirror (all stuff we need is on the USB flash drive)
d-i base-installer/install-recommends boolean false
d-i apt-setup/non-free boolean false
d-i apt-setup/contrib boolean false
d-i apt-setup/use_mirror boolean false
# We will use a local repo for our packages (this repo has not been signed)
d-i debian-installer/allow_unauthenticated boolean true

# Install a standard debian system (some rocommended packages) + openssh-server
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server
d-i pkgsel/upgrade select none
popularity-contest popularity-contest/participate boolean false

d-i grub-installer/only_debian boolean false
d-i grub-installer/with_other_os boolean false

# Avoid that last message about the install being complete
#d-i finish-install/reboot_in_progress note

EOF
    