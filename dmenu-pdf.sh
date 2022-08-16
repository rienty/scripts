#!/bin/bash

#windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)

#target=$(echo "$windows" | grep -E ".*_.*.pdf" | grep -m1 "")
#lu="^0"
#
#for ((i = 1; i < 10; i++)); do	
#	
#	mu=$(bspc query -N -d i)
#	if [[ -z "$mu" ]]; then
#		lu="${lu}\n"
#	fi
#done
#
#nu=$(echo -e "$lu" | dmenu -p "which desktop?" -l 10 -i -x 200 -y 800 -z 2100)

#nu=$(echo -e "^2\n^3\n^4\n^5\n^6\n^7\n^8\n^9" | dmenu -p "Which desktop?" -l 20 -i -x 200 -y 800 -z 2100)
te=$(bspc query -N -d ^3)
if [[ ! -z "$te" ]]; then
		bspc node "$te" -d ^9
fi
nu="^3"

if [ -z "$nu" ]
then
    exit 0
fi

lay_out () {
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
}


#sel=$(find ~/Documents -maxdepth 20 -type f | grep -Eo "Documents*.pdf" | dmenu -i -p Books: -l 23 -fn "Agave Nerd Font:size=16" $colors1  )
sel=$(find ~/documents -maxdepth 20 -type f | sed -r 's/\/.*\///'| dmenu -i -x 220 -y 250 -z 2120 -l 23 )
path=$(find ~/documents -maxdepth 20 -type f | grep $sel)

if [ -z "$sel" ]
then
    exit 0
fi

#text="$(echo -e $sel | sed -r 's/\ +/\\ /g')"
tp=$(echo $sel | sed 's/.*\.//')
#n1=$(xdotool search --class tabbed)

# open_file() {
#         zathura "$path" &
#         sleep 0.8
# 	n2=$(xdotool getwindowfocus)
# }

#barl=$(echo -e "tabbed\nnon-tabbed" | dmenu -i -p Tabbed? -l 5)

if [[ $tp == pdf || $tp == djvu ]]
then
   	bspc desktop -f $nu
	lay_out
   	zathura $path
fi
exit 0

