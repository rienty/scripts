#!/bin/bash

print_desktop(){
mu=$(wmctrl -d | grep -E "\*" | awk '{print $9}')
echo -e "$mu" 
}

print_bat(){
    precent=$(acpi -b | grep 'Battery\ 0' | awk '{print $4}' | grep -Eo "[0-9]+")
    just=$(acpi -b | grep 'Battery\ 0' | awk '{print $3}' | grep -Eo "[A-Za-z]+")
    #	echo -e "${precent}%"
    if [ "$just" == "Charging" ]
    then
	echo -e "+${precent}%"
    else
	echo -e "*${precent}%"
    fi
}

print_date(){
    date=$(date '+%Y-%m-%d')
    echo "$date"
}

print_time(){
	time=$(date '+%H:%M:%S')
	echo "$time"
}

print_volume(){
    volume="$(amixer -c 1 get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
    status="$(amixer -c 1 get Master | tail -n1 | awk '{print $6}')"
      if [ "$volume" -gt 0 ] && [ "$status" == "[on]" ]
      then
         echo -e "${volume}%"
      else
         echo -e "M"
      fi
}

print_backlight() {
    light="$(xbacklight | grep -Eo "^.*\.")"
    echo "scale=0; ${light}" | bc
}

print_disk() {
    disk1=$(lsblk -f | grep sda1 | awk '{print $5}' | sed -r 's/G$//')
    disk0=$(lsblk -f | grep sda5 | awk '{print $5}' | sed -r 's/G$//')
    echo -e "${disk0}G/${disk1}G"
#    echo -e "${disk1}G"
}

print_mem(){
    memfree=$(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}')
    mem=$(echo "scale=2; $memfree/1024/1024" | bc)
    echo "${mem}G"
}

print_cpuinfo(){
    tep0=$(sensors | grep Core\ 0: | awk '{print $3}' | grep -Eo "[0-9.]+")
    tep1=$(sensors | grep Core\ 1: | awk '{print $3}' | grep -Eo "[0-9.]+")
    tep=$(echo "scale=1; ($tep0+$tep1)/2" | bc)
    mg0=$(lscpu -a --extended | grep "0    0      0" | awk '{print $9}')
    mg1=$(lscpu -a --extended | grep "1    0      0" | awk '{print $9}')
    mg2=$(lscpu -a --extended | grep "2    0      0" | awk '{print $9}')
    mg3=$(lscpu -a --extended | grep "3    0      0" | awk '{print $9}')
    mg=$(echo "($mg0+$mg1+$mg2+$mg3)/4" | bc)
    zg=$(echo "scale=2; $mg/1024" | bc | awk '{printf "%.2f",$0}')   
    co=$(sensors | grep Core\ 1: | awk '{print $3}' | grep -Eo "[^+0-9.]+")
    echo -e "${zg}GHz +$tep$co"
}

print_wifi(){
	wifi=$(iw dev wlan0 info | grep ssid | awk '{print $2}')
	if [ -z "$wifi" ]
	then
		echo -e "H"
	else
		echo -e "W"
	fi
}

while true; do
	echo -e "%{l} %{F-}%{B-}%{F#3c3836}%{B#ebdbb2}| $(print_desktop) |%{F-}%{B-}%{c}%{F#504549}%{B#689d6a}| $(print_date) $(print_time) |%{F-}%{B-}  %{r}%{F#3c3836}%{B#b8bb26}| $(print_bat)  $(print_volume)  $(print_backlight)  $(print_wifi) |%{F-}%{B-} "
sleep 1
done
exit 0


