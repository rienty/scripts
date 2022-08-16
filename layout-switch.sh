#!/bin/sh
layout=$(bspc query -T -d | jq -r .layout)
if [ "$layout" = "monocle" ]; then
	bspc config top_padding 0
	pkill lemonbar
    ~/scripts/lemonbar.sh | lemonbar -g 2560x43+0+0 -f 'TerminessTTF Nerd Font:size=20' -B '#282828' &
else
    bspc config top_padding 55
    pkill lemonbar
	~/scripts/lemonbar.sh | lemonbar -g 2536x43+12+12 -f 'TerminessTTF Nerd Font:size=20' -B '#282828' &
fi
