USBPiFi has been installed on the Raspberry Pi that controls your printer. This means that you can easily configured the WiFi connection by editing the included wpa_supplicant.conf file on this flash drive.

Any standard text editor will be able to edit the file. You may need to select the "All Files" option in the file open browser to see wpa_supplicant.conf 

In most cases you will only need to add your WiFi network name (SSID) and password. If your network configuration needs more than that, please see the documentation link in that file.

Once you have edited the file, save it, eject this drive, remove it from your computer, and insert it into any of the USB ports on your printer. Turn on the printer and wait about 5 minutes then pull the drive from the printer. Plug the drive back into your computer and there should now be an ip_address.txt file. This will show both the WiFi (wlan0) and ethernet (eth0) IP addresses. You can connect to Duet Web Control from either.