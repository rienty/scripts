#!/bin/sh

windows=$(wmctrl -xl | awk '{print $5}' | grep -E ".*pdf")
#pdf_w=$(echo "$windows" | grep -E ".*_.*pdf")
#windows_m=$(echo -e "${pdf_w}")
target=$(echo "$windows" | dmenu -l 10 -i -p 'Switch ' -x 220 -y 1000 -z 2120)
nd=$(wmctrl -xl | grep "$target" | awk '{print $1}')
lu=$(bspc query -N -d '^3')
if [[ ! -z "$lu" ]]; then
        bspc node "$lu" -d '^9'
 fi
bspc node "$nd" -d '^3'
bspc desktop -f '^3'
