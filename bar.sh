#/bin/sh
ll=$(echo -e "nobar\ngapbar\nbar" | dmenu -p "Showbar" -l 4 -x 200 -y 800 -z 2125)

if [ -z "$ll" ]
then
    exit 0
fi

pkill lemonbar 


case "$ll" in
	nobar) 
    bspc config top_padding 0
	;;
	gapbar) 
    bspc config top_padding 55
    ~/scripts/lemonbar.sh | lemonbar -g 2536x43+12+12 -f 'GohuFont Nerd Font Mono:size=18' -B '#282828' &
	;;
	bar) 
    bspc config top_padding 0
    ~/scripts/lemonbar.sh | lemonbar -g 2560x43+0+0 -f 'GohuFont Nerd Font Mono:size=18' -B '#282828' &

	;;
esac

