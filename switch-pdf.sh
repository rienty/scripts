#!/bin/sh

windows=$(wmctrl -xl | awk '{print $5}')
pdf_w=$(echo "$windows" | grep -E ".*_.*pdf")
djvu_w=$(echo "$windows" | grep -E ".*djvu")
windows_m=$(echo -e "${pdf_w}\n${djvu_w}")
target=$(echo "$windows_m" | dmenu -l 20 -i -x 220 -y 800 -z 2120)

if [[ -n $target ]]; then
        wmctrl -a "$target"
fi

#
#if [ -z "$target" ]; then
#	exit 0
#fi
#
#nd=$(wmctrl -xl | grep "$target" | awk '{print $1}')
#
#lu=$(bspc query -N -d '^3')
#if [ -n "$lu" ]; then
#        bspc node "$lu" -d '^9'
# fi
#bspc node "$nd" -d '^3'
#bspc desktop -f '^3'
