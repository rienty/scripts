#/bin/sh
exit_justify () {
	if [ -z "$1" ]
	then
		exit 0
	fi
}

nu=$(tmux list-sessions | grep -Eo ^. | dmenu -i -l 10 -x 200 -y 1000 -z 2125)
exit_justify "$nu"
tmux kill-session -t $nu
