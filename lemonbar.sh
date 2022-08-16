#!/bin/bash

print_desktop(){
mu=$(wmctrl -d | grep -E "\*" | awk '{print $9}')
case "$mu" in
	I) lu="\uf8a3"
	;;
	II) lu="\uf8a6"
	;;
	III) lu="\uf8a9"
	;;
	IV) lu="\uf8ac"
	;;
	V) lu="\uf8af"
	;;
	VI) lu="\uf8b2"
	;;
	VII) lu="\uf8b5"
	;;
	VIII) lu="\uf8b8"
	;;
	IX) lu="\uf8bb"
	;;
esac

echo -e "$lu" 
}

print_bat(){
    pre=$(acpi -b | grep 'Battery\ 0' | awk '{print $4}' | grep -Eo "[0-9]+")
	if [[ $pre -le 10 ]]; then
		precent="\uf579"
	elif [[ $pre -le 20 ]]; then
		precent="\uf57a"
	elif [[ $pre -le 30 ]]; then
		precent="\uf57b"
	elif [[ $pre -le 40 ]]; then
		precent="\uf57c"
	elif [[ $pre -le 50 ]]; then
		precent="\uf57d"
	elif [[ $pre -le 60 ]]; then
		precent="\uf57e"
	elif [[ $pre -le 70 ]]; then
		precent="\uf57f"
	elif [[ $pre -le 80 ]]; then
		precent="\uf580"
	elif [[ $pre -le 90 ]]; then
		precent="\uf581"
	elif [[ $pre -le 100 ]]; then
		precent="\uf578"
	fi
	
	if [[ $pre -le 20 ]]; then
		ch_pre="\uf585"
	elif [[ $pre -le 30 ]]; then
		ch_pre="\uf586"
	elif [[ $pre -le 40 ]]; then
		ch_pre="\uf587"
	elif [[ $pre -le 60 ]]; then
		ch_pre="\uf588"
	elif [[ $pre -le 80 ]]; then
		ch_pre="\uf589"
	elif [[ $pre -le 90 ]]; then
		ch_pre="\uf58a"
	elif [[ $pre -le 100 ]]; then
		ch_pre="\uf583"
	fi


    just=$(acpi -b | grep 'Battery\ 0' | awk '{print $3}' | grep -Eo "[A-Za-z]+")
    #	echo -e "${precent}%"
    if [ "$just" == "Charging" ]
    then
	echo -e "${ch_pre}"
    else
	echo -e "${precent}"
    fi
}

print_date(){
    date=$(date '+%m-%d')
    echo "\uf015 $date"
}

print_time(){
	time=$(date '+%H:%M')
	echo "\uf51f $time"
}

print_volume(){
    vol="$(amixer -c 1 get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
	if [[ $vol -le 40 ]]; then
		volume="\ufa7e"	
	elif [[ $vol -le 60 ]]; then
		volume="\ufa7f"
	elif [[ $vol -le 80 ]]; then
		volume="\ufa7d"
	elif [[ $vol -le 100 ]]; then
		volume="\uf028"
	fi
    status="$(amixer -c 1 get Master | tail -n1 | awk '{print $6}')"
    if [ "$vol" -gt 0 ] && [ "$status" == "[on]" ]
    then
        echo -e "${volume}"
    else
        echo -e "\ufa80"
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
		echo -e "\uf2ad"
	else
		echo -e "\uf143"
	fi
}

while true; do
	
	echo -e "%{l} %{F-}%{B-}%{F#3c3836}%{B#ebdbb2}| $(print_desktop) |%{F-}%{B-}%{c}%{F#504549}%{B#689d6a}| $(print_date) $(print_time) |%{F-}%{B-}  %{r}%{F#3c3836}%{B#b8bb26}| $(print_bat)  $(print_volume)  $(print_wifi) |%{F-}%{B-} "
sleep 1
done
exit 0


