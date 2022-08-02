#!/bin/bash

# functions

print_volume() {
	volume="$(amixer -c 1 get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
	status="$(amixer -c 1 get Master | tail -n1 | awk '{print $6}')"
	if [ "$volume" -gt 0 ] && [ "$status" == "[on]" ]
	then
		echo -e "${volume}%"
	else
		echo -e "M"
	fi
}

print_bat(){
	precent=$(acpi -b | grep 'Battery\ 0' | awk '{print $4}' | grep -Eo "[0-9]+")
	just=$(acpi -b | grep 'Battery\ 0' | awk '{print $3}' | grep -Eo "[A-Za-z]+")
	if [ $just == "Charging" ]
	then
		echo -e "+${precent}%"
	else
		echo -e "${precent}%"
	fi
}


print_wifi() {
	wifi=$(iw dev wlan0 info | grep ssid | awk '{print $2}')
	if [ -z "$wifi" ]
	then
		echo -e "H"
	else
		echo -e "W"
	fi
}


print_date(){
	#  date=$(date '+%m-%d %H:%M')
	date=$(date '+%H:%M')
	echo "$date"
}

xsetroot -name "  $(print_volume)  $(print_wifi)  $(print_bat)  $(print_date) "

exit 0
