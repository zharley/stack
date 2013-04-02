## Device configuration

Configure partitions in preparation for bare-bones Ubuntu setup.

### Partitions

A simple configuration is three partitions (boot, swap, root) with fixed sizes allocated to each of the first two and the remainder allocated to the third.

    Disk /dev/sda: 1000.2 GB, 1000204886016 bytes
    255 heads, 63 sectors/track, 121601 cylinders, total 1953525168 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0xffffffff

       Device Boot      Start         End      Blocks   Id  System
    /dev/sda1              63      224909      112423+  83  Linux
    /dev/sda2          224910     4433939     2104515   83  Linux
    /dev/sda3         4433940  1953520064   974543062+  83  Linux

Example configuration:

    read -p "Device (e.g. /dev/sda): " MY_DEVICE
    read -p "Boot partition size (e.g. 150M): " MY_BOOT_SIZE
    read -p "Swap partition size (e.g. 1G): " MY_SWAP_SIZE

    # o   create a new empty partition table
    # n   add a new partition
    # w   write table to disk and exit
    MY_FDISK="o\nn\np\n1\n\n+${MY_BOOT_SIZE}\nn\np\n2\n\n+${MY_SWAP_SIZE}\nn\np\n3\n\n\n\np\nw\n"

Execute partitioning as one command. **Warning**: This will wipe out any data on the device.

    echo -e $MY_FDISK | fdisk $MY_DEVICE

### RAID

The following is the most basic RAID1 setup with [mdadm](http://en.wikipedia.org/wiki/Mdadm).

Configuration (device 2 can either be missing or an actual device):

    read -p "First RAID device (e.g. /dev/sda3): " MY_RAID_DEVICE1
    read -p "Second RAID device (e.g. /dev/sdb3 or missing): " MY_RAID_DEVICE2

Setup mdadm. **Warning**: This will wipe out any data on the device.

    apt-get -y install mdadm
    mdadm --verbose --create /dev/md0 --level=1 --raid-devices=2 $MY_RAID_DEVICE1 $MY_RAID_DEVICE2

### Key device setup (if applicable)

The following checks, wipes and formats a device. **Warning**: This will wipe out any data on the device.

    read -p "Device (e.g. /dev/sda): " MY_KEY_DEVICE

Wipe, format as ext2.

    # badblocks will wipe and also test the usb device
    #
    # -e max                bad blocks before aborting
    # -t random             test pattern
    # -s                    progress
    # -v                    verbose
    # -w                    write test mode
    # -c 10240              check 10K blocks at a time
    badblocks -e 1 -t random -s -w -c 10240 $MY_KEY_DEVICE
    
    # format as ext2 and mount
    mkfs.ext2 $MY_KEY_DEVICE 

## Installation

Install Ubuntu 12.04, optionally using cryptsetup for disk encryption.

### Configuration

Get sample configuration file. Edit as necessary.

    wget https://raw.github.com/zharley/stack/master/etc/setup.conf

    vim setup.conf

    source setup.conf

### Encryption

Generate a key file containing random bytes (the quality of which depends on the randomness of **/dev/random**).

    # mount
    mkdir -p /mnt && mount $MY_KEY_DEVICE /mnt
    
    # generate a random key (32 bytes = 256 bits)
    dd if=/dev/random of=/mnt/$MY_KEY_NAME bs=1 count=32

    # unmount
    umount /mnt

Use [cryptsetup](http://code.google.com/p/cryptsetup/) to encrypt a device. **Warning**: This will wipe out any data on the device.

    apt-get -y install cryptsetup
    modprobe dm-crypt

    # mount key device (optional)
    mkdir -p /mnt && mount $MY_KEY_DEVICE /mnt

    # LUKS format
    cryptsetup $MY_CRYPTSETUP_FORMAT

    # LUKS open
    cryptsetup $MY_CRYPTSETUP_OPEN

    # unmount key device (optional)
    umount /mnt

    # format encrypted root as ext4
    mkfs.ext4 /dev/mapper/root

### Bootstrapping

Prepare devices

    # format boot partition as ext2
    mkfs.ext2 $MY_BOOT_DEVICE

    # mount root and boot partitions
    mkdir -p /mnt && mount /dev/mapper/root /mnt
    mkdir -p /mnt/boot && mount $MY_BOOT_DEVICE /mnt/boot

Do a minimal install of Ubuntu using debootstrap.

    # install debootstrap
    wget $MY_DEBOOTSTRAP -O /tmp/debootstrap.deb 
    dpkg -i /tmp/debootstrap.deb

    # launch debootstrap
    debootstrap --include=$MY_BASE --components=$MY_SOURCES --verbose --arch $MY_ARCH $MY_DISTRO /mnt $MY_MIRROR

Add matching sources.list:

    cat << EOF > /mnt/etc/apt/sources.list
    # binary packages
    deb $MY_MIRROR $MY_DISTRO $MY_SOURCES_SPACED
    deb $MY_MIRROR $MY_DISTRO-updates $MY_SOURCES_SPACED
    deb $MY_MIRROR $MY_DISTRO-security $MY_SOURCES_SPACED
    
    # source packages
    #deb-src $MY_MIRROR $MY_DISTRO $MY_SOURCES_SPACED
    #deb-src $MY_MIRROR $MY_DISTRO-updates $MY_SOURCES_SPACED
    #deb-src $MY_MIRROR $MY_DISTRO-security $MY_SOURCES_SPACED
    EOF

### Boot Configuration

Configure **crypttab** (if applicable) **with key file** using persistent device names:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root $MY_ROOT_DEVICE_ID $MY_KEY_DEVICE_ID/$MY_KEY_NAME luks,keyscript=/usr/local/sbin/keyscript
    EOF

    wget https://raw.github.com/zharley/stack/master/etc/keyscript -O /mnt/usr/local/sbin/keyscript
    chmod 755 /mnt/usr/local/sbin/keyscript

Configure **crypttab** (if applicable) **without key file**:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root $MY_ROOT_DEVICE_ID none luks
    EOF

Configure **fstab**:

    cat << EOF > /mnt/etc/fstab
    # /etc/fstab: static file system information.
    #
    # <file system>    <mount point>   <type>  <options>                   <dump>  <pass>
    proc               /proc           proc    defaults                    0       0
    # boot: $MY_BOOT_DEVICE
    $MY_BOOT_DEVICE_ID /boot           ext2    relatime                    0       2
    # swap: $MY_SWAP_DEVICE
    /dev/mapper/swap   none            swap    sw                          0       0
    # root: $MY_ROOT_DEVICE
    /dev/mapper/root   /               ext4    relatime,errors=remount-ro  0       1
    EOF

Configure network interfaces:

    cat << EOF > /mnt/etc/network/interfaces
    # Loopback network interface
    auto lo
    iface lo inet loopback
    
    # Wired device with DHCP
    auto eth0
    iface eth0 inet dhcp
    
    # Wireless device with DHCP
    # auto wlan0
    # iface wlan0 inet dhcp
    
    # Wired device with static IP
    # auto eth0
    # iface eth0 inet static
    #   address 192.168.1.111
    #   netmask 255.255.255.0
    #   network 192.168.1.0
    #   broadcast 192.168.1.255
    #   gateway 192.168.1.1
    #   dns-nameservers 8.8.8.8 8.8.4.4
    EOF

Set hostname and hosts:
    
    # set hostname
    echo $MY_HOSTNAME > /mnt/etc/hostname

    # install hosts file
    cat << EOF > /mnt/etc/hosts
    127.0.0.1 localhost $MY_HOSTNAME 
    ::1             localhost ip6-localhost ip6-loopback
    fe00::0         ip6-localnet
    ff00::0         ip6-mcastprefix
    ff02::1         ip6-allnodes
    ff02::2         ip6-allrouters
    EOF
    
Update packages, setup grub and initramfs.

    # mount devices under /mnt
    for DIR in proc dev sys; do mount --bind /$DIR /mnt/$DIR; done
    
    # update packages
    chroot /mnt apt-get update
    
    # install grub
    chroot /mnt apt-get install grub-pc
    
    # during installation select boot device or install grub manually here
    # chroot /mnt grub-install /dev/sda

    # remove quiet splash from boot options, to see more details
    sed --in-place='.old' 's:GRUB_CMDLINE_LINUX_DEFAULT="quiet splash":GRUB_CMDLINE_LINUX_DEFAULT="":' /mnt/etc/default/grub
    chroot /mnt update-grub

    # setup initramfs
    cat << EOF > /mnt/etc/initramfs-tools/modules
    # List of modules that you want to include in initramfs
    mmc_block
    sdhci
    sdhci_pci
    EOF

    chroot /mnt update-initramfs -u
    
    # set root password
    chroot /mnt passwd

    cp setup.conf /mnt/boot/setup.`date +%Y-%m-%d`.conf

## Post Configuration

### Miscellaneous
    
Set timezone:

    # set timezone 
    echo "America/New_York" > /mnt/etc/timezone
    chroot /mnt dpkg-reconfigure --frontend noninteractive tzdata
    chroot /mnt ntpdate pool.ntp.org

Add a non-root admin user:

    read -p "Admin username: " MY_USER
    
    # create primary admin user
    chroot /mnt adduser $MY_USER
    chroot /mnt usermod -G admin -a $MY_USER

Setting up firewall:

    # some networking essentials and ufw
    apt-get -y install traceroute dnsutils telnet build-essential
    apt-get -y install ufw

    ufw default deny
    ufw allow 22
    ufw enable

    # disable access to IP ranges
    ufw deny out to 192.168.1.0/24

    # block IP address has after attempting 6 connections in 30 seconds
    ufw limit ssh

Setting up unattended upgrades:

    apt-get -y install unattended-upgrades

    cat << EOF > /etc/apt/apt.conf.d/10periodic
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Download-Upgradeable-Packages "1";
    APT::Periodic::AutocleanInterval "7";
    APT::Periodic::Unattended-Upgrade "1";
    EOF

Setting up mail:

    # Select "internet site" for default setup
    apt-get -y install postfix

    read -p "Email address (e.g. me@example.com): " MY_RECIPIENT
    cat << EOF | sendmail -f "root@`hostname`" $MY_RECIPIENT
    Subject: Test from `hostname`
    To: $MY_RECIPIENT
    From: root@`hostname`
    If you've received this message, then the server is able to send email. 
    EOF
