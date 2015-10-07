# Do a fresh install, not an upgrade
install

# Language for the install
lang en_GB.UTF-8

# The keyboard type
keyboard uk

# The timezone for this system
timezone --utc Europe/London

# Configure one or more NICs
network --onboot yes --device eth0 --bootproto dhcp --noipv6

# The root password
rootpw --iscrypted $1$UhHVki6U$187/tUM7fVo0MK7IHz5f0. #--plaintext Passw0rd!

# Firewall
firewall --enabled

# Authentication options for the system
auth  --useshadow  --enablemd5

# Security Enhanced Linux
selinux --disabled

# Bootloader options
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"

# Do not configure X
skipx

# Do not use the GUI
text

# Initialises any invalid partition tables found on disks (optional)
zerombr

# Remove existing partitions for a clean install
clearpart --all --initlabel --drives=sda

# Disk partitioning information
part /boot --fstype ext4 --size=500
part swap --size=1024
part pv.01 --size=1 --grow
volgroup vg_root pv.01
logvol / --vgname=vg_root --size=1 --grow --name=lv_root
logvol /var --vgname=vg_root --size=4096 --name=lv_var
logvol /tmp --vgname=vg_root --size=2048 --name=lv_tmp


# Disable the firstboot programme
firstboot --disabled

# Reboot the server after the install
reboot

# Define online repositories for packages to install
url --url http://centos.mirrors.hoobly.com/7.1.1503/os/x86_64/
repo --name=epel --baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64/
repo --name=updates --baseurl=http://centos.mirrors.hoobly.com/7.1.1503/updates/x86_64/

# Define the manifest of rpm packages to install
%packages --nobase
  @core
	epel-release
	kernel-devel
	kernel-headers
	make
	dkms
	bzip2
	wget
	openssh-clients
	nano
	htop
	perl
	net-tools
%end

%post
  exec < /dev/console > /dev/console
  echo "\nTurning off unneeded services\n"
  chkconfig sendmail off
  chkconfig smartd off
  chkconfig cupsd off

  printf "\nDisabling TTY so that sudo can be called without users being logged in a text only console\n"
  sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

  printf "\nInstalling the GNOME Desktop\n"
  yum -y groupinstall "gnome-desktop" "graphical-admin-tools"

  printf "\nEnabling the GUI on system start\n"
  systemctl set-default graphical.target
  
%end
