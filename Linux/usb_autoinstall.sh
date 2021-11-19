#/usr/bin/env bash
RELEASE="bullseye"
echo "Custom USB Debian Installer with preseed"
# Based on https://gist.github.com/ageekymonk/3d691d89c14da837955c
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
mkdir /mnt/usb/hdmedia-wheezy
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

# We don't need network as all stuff is contained in the USB flash drive
d-i netcfg/enable boolean false
d-i netcfg/wireless_wep string

# Don't prompt for firmware
d-i hw-detect/load_firmware boolean true

# We only create a root user
d-i passwd/make-user boolean false
d-i passwd/root-password password Sw0rdf1sh
d-i passwd/root-password-again password Sw0rdf1sh

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

###############################################################################
# User creation
###############################################################################
# Skip creation of a root account (normal user account will be able to use sudo).
# run 'mkpasswd -m sha-512' to generate password
d-i passwd/root-login boolean true
d-i passwd/root-password-crypted password $6$wzSPKbDwl0GrN8pd$SyD4SkScp4.AXiU2VaUWKzBGmMUbaqbNNxFppJ9P07Bew02oddEGp6tu9jY9QP2eCk0LDBryDeL2wES3DxilM.

d-i passwd/username string sidcm
d-i passwd/user-fullname string Setor de Informatica
d-i passwd/user-password-crypted password $6$wzSPKbDwl0GrN8pd$SyD4SkScp4.AXiU2VaUWKzBGmMUbaqbNNxFppJ9P07Bew02oddEGp6tu9jY9QP2eCk0LDBryDeL2wES3DxilM.

d-i passwd/user-default-groups string {{ LINUX_GROUPS_COMMON|join(' ') }}

# We only create a root user
d-i passwd/make-user boolean false
d-i passwd/root-password password Sw0rdf1sh
d-i passwd/root-password-again password Sw0rdf1sh

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
    