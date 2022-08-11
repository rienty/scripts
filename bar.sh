#/bin/sh
ll=$(echo -e "cm-bar\nvb-bar" | dmenu -p "Showbar" -l 4 -x 200 -y 800 -z 2125)

if [ -z "$ll" ]
then
    exit 0
fi

pkill lemonbar 

case "$ll" in
	cm-bar) 
    cp ~/scripts/lemonbar-sys.sh ~/scripts/lemonbar.sh ;;
	vb-bar) 
    cp ~/scripts/lemonbar.sh ~/scripts/lemonbar.sh ;;
esac

