#/bin/sh

exit_justify () {
	if [ -z "$1" ]
	then
		exit 0
	fi
}

tm=$(ps ax | grep tmux | awk '{print $5}' | grep -Eo "tmux")

if [[ -z "$tm" ]]; then
	st -e tmux
else
    ms=$(echo -e "New\nOld" | dmenu -i -l 3 -x 200 -y 1000 -z 2125) 
	exit_justify "$ms"
	case "$ms" in
		New) st -e tmux
		;;
		Old) 
	nu=$(tmux list-sessions | grep -Eo ^. | dmenu -i -l 10 -x 200 -y 1000 -z 2125)
	exit_justify "$nu"
	st -e tmux attach-session -t $nu
		;;
	esac
fi
