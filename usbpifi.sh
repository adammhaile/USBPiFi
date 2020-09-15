#!/usr/bin/env bash

set -x

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BACKUPDIR=/root/backup/

DO_RECONFIG=false
USB_DIR=

# give the system some time to fully boot
sleep 30

shopt -s nullglob
for f in /media/*/wpa_supplicant.{txt,conf}
do
    USB_DIR=$(dirname ${f})
    echo "Found ${f}"
    # backup the old file, just in case
    echo "Backing up old wpa_supplicant.conf"
    cp -f /etc/wpa_supplicant/wpa_supplicant.conf ${BACKUPDIR}/wpa_supplicant.conf.backup
    echo "Copying new wpa_supplicant.conf"
    cp -f ${f} /etc/wpa_supplicant/wpa_supplicant.conf
    # set flag for later reconfig of wlan0
    DO_RECONFIG=true
    # could be in any USB drive be we are assuming only one *should* 
    # exist, so bail after the first
    break
done

if [ ${DO_RECONFIG} = true ];
then
    echo "Reconfiguring wifi with new wpa_supplicant"
    /usr/bin/systemctl daemon-reload
    /usr/bin/systemctl restart dhcpcd
    sleep 5
    /usr/sbin/wpa_cli -i wlan0 reconfigure
    mv -f ${USB_DIR}/wpa_supplicant.txt ${USB_DIR}/wpa_supplicant.txt.loaded
    mv -f ${USB_DIR}/wpa_supplicant.conf ${USB_DIR}/wpa_supplicant.conf.loaded
fi

echo "Waiting for full network connection"
sleep 30

ETH=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
WLAN=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
echo "wlan0: ${WLAN}"
echo "eth0: ${ETH}"

# output to any USB in case we are not reconfiguring
awk '/media\/usb/{print $2}' /proc/mounts | while read line;
do
    echo "Writing ${line}/ip_address.txt"
    echo $(date) > ${line}/ip_address.txt
    echo "wlan0: ${WLAN}" >> ${line}/ip_address.txt
    echo "eth0: ${ETH}" >> ${line}/ip_address.txt
done

