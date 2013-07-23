## Device configuration

Configure partitions in preparation for bare-bones Ubuntu setup. This assumes that the system is booted in a recovery or live CD environment.

### Partitions

This creates a simple [GUID Partition Table](http://en.wikipedia.org/wiki/GUID_Partition_Table) with four partitions (grub, boot, swap, root) with fixed sizes allocated for all but the last, which uses the bulk of the disk. It is necessary to use **parted** (or the gui version **gparted**) rather than **fdisk** in order to create [partitions larger than 2TB](http://www.cyberciti.biz/tips/fdisk-unable-to-create-partition-greater-2tb.html).

The partitions:

1. grub (2MiB): Dedicated BIOS boot partition for booting in [legacy MBR mode](https://help.ubuntu.com/community/UEFI) (required for old hardware).

2. boot (200MiB): Boot parition.

3. swap (1000MiB): Swap parition.

4. root (remainder): Root partition

**Warning**: This will destroy any existing partition table on the device, so make sure it is the right device and data is backed up.

    read -p "Device (e.g. /dev/sda): " MY_DEVICE
    parted $MY_DEVICE mklabel gpt
    parted $MY_DEVICE mkpart grub 1MiB 3MiB
    parted $MY_DEVICE mkpart boot 3MiB 203MiB
    parted $MY_DEVICE mkpart swap 203MiB 1203MiB
    parted $MY_DEVICE mkpart root 1203MiB -- -1
    parted $MY_DEVICE set 1 bios_grub on
    parted $MY_DEVICE print free

### RAID

The following is the most basic RAID1 setup with [mdadm](http://en.wikipedia.org/wiki/Mdadm).

Configuration (device 2 can either be missing or an actual device):

    read -p "First RAID device (e.g. /dev/sda4): " MY_RAID_DEVICE1
    read -p "Second RAID device (e.g. /dev/sdb4 or missing): " MY_RAID_DEVICE2

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
    
    cat /mnt/etc/apt/sources.list

### Cryptsetup

#### With key file

Install a keyscript.

    wget https://raw.github.com/zharley/stack/master/etc/keyscript -O /mnt/usr/local/sbin/keyscript
    chmod 755 /mnt/usr/local/sbin/keyscript

Use the RAID device:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root /dev/md0 $MY_KEY_DEVICE_ID/$MY_KEY_NAME luks,keyscript=/usr/local/sbin/keyscript
    EOF

**Or** use persistent device name for root partition:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root $MY_ROOT_DEVICE_ID $MY_KEY_DEVICE_ID/$MY_KEY_NAME luks,keyscript=/usr/local/sbin/keyscript
    EOF

#### Without key file

Use the RAID device:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root /dev/md0 none luks
    EOF

**Or** use persistent device name for root partition:

    cat << EOF > /mnt/etc/crypttab
    # <target name> <source device> <key file> <options>
    swap $MY_SWAP_DEVICE_ID /dev/urandom swap
    root $MY_ROOT_DEVICE_ID none luks
    EOF

#### Verify

    cat /mnt/etc/crypttab

### Filesystems and networking

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

    cat /mnt/etc/fstab

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

    cat /mnt/etc/network/interfaces

Set hostname and hosts:
    
    # set hostname
    echo $MY_HOSTNAME > /mnt/etc/hostname

    cat /mnt/etc/hostname

    # install hosts file
    cat << EOF > /mnt/etc/hosts
    127.0.0.1 localhost $MY_HOSTNAME 
    ::1             localhost ip6-localhost ip6-loopback
    fe00::0         ip6-localnet
    ff00::0         ip6-mcastprefix
    ff02::1         ip6-allnodes
    ff02::2         ip6-allrouters
    EOF
    
    cat /mnt/etc/hosts

### Chroot and boot
    
Update packages, setup grub and initramfs.

    # mount devices under /mnt
    for DIR in proc dev sys; do mount --bind /$DIR /mnt/$DIR; done
    
    # update packages
    chroot /mnt apt-get update
    
    # install grub: menu appears to select boot device
    chroot /mnt apt-get install grub-pc

    # remove quiet splash from boot options, to see more details
    sed --in-place='.old' 's:GRUB_CMDLINE_LINUX_DEFAULT="quiet splash":GRUB_CMDLINE_LINUX_DEFAULT="bootdegraded=true":' /mnt/etc/default/grub

    cat /mnt/etc/default/grub

    chroot /mnt update-grub

    # setup initramfs
    cat << EOF > /mnt/etc/initramfs-tools/modules
    # List of modules that you want to include in initramfs
    mmc_block
    sdhci
    sdhci_pci
    EOF

    cat /mnt/etc/initramfs-tools/modules

    chroot /mnt update-initramfs -u
    
    # set root password
    chroot /mnt passwd

    cp setup.conf /mnt/boot/setup.`date +%Y-%m-%d`.conf

## Post Configuration

After rebooting, log into new system.

### Miscellaneous
    
Set timezone:

    # set timezone 
    echo "America/New_York" > /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
    ntpdate pool.ntp.org

Set default language and locale:

    cat << EOF >> /etc/environment
    LANG="en_CA.UTF-8"
    LANGUAGE="en_CA"
    EOF

Setup a priviledged non-root user:

    read -p "Add user: " MY_USER
    adduser $MY_USER

    # adm      Can view log files in /var/log
    # admin    Can sudo
    # audio    Can access sound devices
    # cdrom    Can access optical disks
    # fuse     Can access File System User Space 
    # lpadmin  Can change printer settings
    # netdev   Can administer network and wireless
    # video    Can access video devices
    MY_GROUPS="adm,admin,audio,cdrom,fuse,lpadmin,netdev,video"
    for g in $(echo $MY_GROUPS | tr ',' ' '); do groupadd -f $g; done
    usermod -G $MY_GROUPS -a $MY_USER

    cd /home/$MY_USER
    chmod -R 0700 .
    sudo -u $MY_USER mkdir -p tmp
    sudo -u $MY_USER mkdir -p mnt/{usb,ssh,ftp,hdd,cdrom,attach}

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

Enable common Apache modules:

    # apache modules
    a2enmod proxy_balancer proxy_http rewrite

### Trap all outgoing mail

Install Perl-Compatible Regular Expressions for postfix.

    apt-get install postfix-pcre

Create a destinations file:

    vim /etc/postfix/mydestinations

Make this server the final destination for all messages:

    /.*/    ACCEPT

Edit main config:

    vim /etc/postfix/main.cf

Use the pcre file and set "catch all" mailbox. Also set **local\_recipent\_maps**, otherwise non-local domains will be rejected.

    mydestination = pcre:/etc/postfix/mydestinations
    local_recipient_maps =
    luser_relay = $MY_USER@localhost

Add local IMAP server:

    apt-get install dovecot-imapd

Edit main Dovecot configuration:

    vim /etc/dovecot/dovecot.conf

Uncomment this line to listen on the default interface.

    listen = *, ::

Edit mail configuration:

    vim /etc/dovecot/conf.d/10-mail.conf

Set the mail location to the mbox:

    mail_location = mbox:~/mail:INBOX=/var/mail/%u

Restart dovecot:

    /etc/init.d/dovecot restart

Test login (Ctrl+] to exit):

    telnet localhost 143
    a login username password

Login should now be possible via Thunderbird or other mail client.

### Desktop

Remove auto-generated directories and register absence of these directories with desktop settings manager.

    rmdir {Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Videos}
    xdg-user-dirs-update

Remove graphical login window:

    update-rc.d -f xdm remove

## Recovery

### Preliminary

    apt-get update && apt-get -y install vim mdadm cryptsetup

    modprobe dm-crypt

    # start raid
    mdadm --verbose --assemble /dev/md0 /dev/sda3

    # mount key device (optional)
    mkdir -p /mnt && mount $MY_KEY_DEVICE /mnt

    # LUKS open
    cryptsetup $MY_CRYPTSETUP_OPEN

    # unmount key device (optional)
    umount /mnt

    # mount root and boot partitions
    mkdir -p /mnt && mount /dev/mapper/root /mnt
    mkdir -p /mnt/boot && mount $MY_BOOT_DEVICE /mnt/boot

    # mount devices under /mnt
    for DIR in proc dev sys; do mount --bind /$DIR /mnt/$DIR; done

### Reinstall GRUB

    chroot /mnt grub-install /dev/sda
    chroot /mnt update-grub
