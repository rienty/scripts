#!/bin/sh
#bspc desktop -f ^1
layout=$(bspc query -T -d | jq -r .layout)
if [ "$layout" = "monocle" ]; then
    
	bspc config top_padding 0
	pkill lemonbar
    ~/scripts/lemonbar.sh | lemonbar -g 2560x43+0+0 -f 'GohuFont Nerd Font Mono:size=18' -B '#282828' &
else
    bspc config top_padding 55
    pkill lemonbar
	~/scripts/lemonbar.sh | lemonbar -g 2536x43+12+12 -f 'GohuFont Nerd Font Mono:size=18' -B '#282828' &
fi

