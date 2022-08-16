#!/bin/bash

#te=$(bspc query -N -d ^3)
#if [ -n "$te" ]; then
#		bspc node "$te" -d ^9
#fi
nu="^3"

#if [ -z "$nu" ]
#then
#    exit 0
#fi

#lay_out () {
#layout=$(bspc query -T -d | jq -r .layout)
#if [ "$layout" = "monocle" ]; then
#    
#	bspc config top_padding 0
#	pkill lemonbar
#    ~/scripts/lemonbar.sh | lemonbar -g 2560x43+0+0 -f 'TerminessTTF Nerd Font:size=20' -B '#282828' &
#else
#    bspc config top_padding 55
#    pkill lemonbar
#	~/scripts/lemonbar.sh | lemonbar -g 2536x43+12+12 -f 'TerminessTTF Nerd Font:size=20' -B '#282828' &
#fi
#}

sel=$(find ~/documents -maxdepth 20 -type f | sed -r 's/\/.*\///'| dmenu -i -x 220 -y 250 -z 2120 -l 23 )
path=$(find ~/documents -maxdepth 20 -type f | grep "$sel")

if [ -z "$sel" ]
then
    exit 0
fi

tp=$(echo -e "$sel" | sed 's/.*\.//')

if [[ "$tp" == pdf || "$tp" == djvu ]]
then
   	bspc desktop -f "$nu"
	bspc desktop -l monocle
   	zathura "$path"
fi
exit 0

