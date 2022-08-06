#!/bin/bash

sel=$(echo -e "oneplus\ncnu\nhome\nwpa-off\niw-off" | dmenu -i -p "Which WiFi to be connected?" -l 20 -x 200 -y 1000 -z 2125)

if [ -z "$sel" ]
then
    exit 0
fi

sudo pkill wpa_supplicant && sudo iw dev wlan0 disconnect
sudo pkill v2ray 

case "$sel" in
    oneplus)
           sudo pkill wpa_supplicant 
           sudo wpa_supplicant -i wlan0 -c ~/scripts/oneplus.conf -B 
		   v2ray -c ~/scripts/config.json & ;;
       home)
	   sudo pkill wpa_supplicant
	   sudo wpa_supplicant -i wlan0 -c ~/scripts/home.conf -B 
	   v2ray -c ~/scripts/config.json & ;;
       cnu)
	   sudo iw dev wlan0 disconnect
	   sudo iw dev wlan0 connect CNU
	   v2ray -c ~/scripts/config.json & 
	   sleep 5
	   qutebrowser http://192.168.1.91 ;;
    wpa-off)
	   sudo pkill wpa_supplicant
	   sudo pkill v2ray ;;
    iw-off)
	   sudo iw dev wlan0 disconnect
	   sudo pkill v2ray ;;
esac

exit 0
