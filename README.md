# USBPiFi

This script aims to solve the problem of provisioning the network on a headless Raspberry Pi device in a production environment. Sadly there is no way for this to work with a completely clean official Raspberry Pi OS (formerly Raspbian) so the intent is to install this script to a system, create an image of that OS install, and then use that image for all future distribution.

Currently this has been tested only with Raspberry Pi OS Lite on the Pi 3B+ and Pi 4.

The installer will handle the following tasks:

- Install usbmount (required for automatic mounting on Pi OS Lite)
- Backup original udevd and wpa_supplicant files
- Update udevd and usbmount configs to work properly
- Install the usbpifi.sh script to root
- Setup the root cron to run usbpifi.sh on boot

With all that done, USBPiFi will load any wpa_supplicant.conf file in the root of an inserted USB drive at boot and reconfigure WiFi to use that config immediately. No reboot needed. But it will also persist reboots. After loading the configuration it will rename it on disk so that it will not be loaded again if the drive is left installed.

Finally, regardless of installing a new WiFi config or not it will write an ip_address.txt file containing both the wlan0 and eth0 IP addresses. So this can even be used to discover the IP address of a wired connection if desired.