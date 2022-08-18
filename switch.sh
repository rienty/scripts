#!/bin/sh

windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)
st_w=$(echo "$windows" | grep -vE ".*pdf")
windows_m=$(echo -e "${st_w}")
target=$(echo "$windows_m" | dmenu -l 10 -i -x 220 -y 1000 -z 2120)

if [[ -n $target ]]; then
        wmctrl -a "$target"
fi


