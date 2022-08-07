#!/bin/sh

windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)
pdf_w=$(echo "$windows" | grep -E ".*_.*pdf")
st_w=$(echo "$windows" | grep -vE ".*_.*pdf")
windows_m=$(echo -e "${pdf_w}\n${st_w}")
target=$(echo "$windows_m" | dmenu -l 10 -i -p 'Switch ' -x 200 -y 1000 -z 2125)

if [[ -n $target ]]; then
        wmctrl -a "$target"
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

fi


