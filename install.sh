#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BACKUPDIR=/root/backup/
mkdir -p ${BACKUPDIR}

echo "Installing usbmount"
apt-get install usbmount

echo "Backing up files"
cp -f /etc/usbmount/usbmount.conf ${BACKUPDIR}
cp -f /lib/systemd/system/systemd-udevd.service ${BACKUPDIR}
cp -f /etc/wpa_supplicant/wpa_supplicant.conf ${BACKUPDIR}

echo "Updating configuration"

sed 's/FS_MOUNTOPTIONS=.*/FS_MOUNTOPTIONS="-fstype=vfat,gid=users,dmask=0007,fmask=0117"/g' ${BACKUPDIR}/usbmount.conf > /etc/usbmount/usbmount.conf

sed -e 's/PrivateMounts=.*/PrivateMounts=no/g' -e 's/MountFlags=.*//g' ${BACKUPDIR}/systemd-udevd.service > /lib/systemd/system/systemd-udevd.service

echo "MountFlags=shared" >> /lib/systemd/system/systemd-udevd.service

echo "Installing usbpifi script"
cp -f ./usbpifi.sh /root/usbpifi.sh
chmod +x /root/usbpifi.sh

RUN_LINE="@reboot /root/usbpifi.sh"

crontab -l > /tmp/crontab
grep -qs usbpifi /tmp/crontab

if [ $? -eq 1 ]; then
    echo "No existing USBPiFi cron, installing..."
    echo ${RUN_LINE} >> /tmp/crontab
    crontab -u root /tmp/crontab
fi

echo "Done!"