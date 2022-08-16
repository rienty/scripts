#!/bin/sh

windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)
st_w=$(echo "$windows" | grep -vE ".*pdf")
windows_m=$(echo -e "${st_w}")
target=$(echo "$windows_m" | dmenu -l 10 -i -p 'Switch ' -x 220 -y 1000 -z 2120)

if [[ -n $target ]]; then
        wmctrl -a "$target"
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

fi


