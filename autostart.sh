#!/bin/bash

/bin/bash ~/scripts/dwm-status.sh &

feh --bg-fill ~/scripts/wallpapers/world.jpg

sudo cpupower frequency-set --governor conservative

sudo bash ~/scripts/wakeup.sh &

xbacklight -set 15 &
xss-lock --transfer-sleep-lock -- i3lock -c 000000 --nofork &
xautolock -time 10 -locker "i3lock -c 000000" &

clipmenud &
#pulseaudio &

fcitx5 &

sleep 2

xmodmap ~/.config/Xmodmap
