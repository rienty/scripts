#!/bin/sh

exit_justify () {
	if [ -z "$1" ]
	then
		exit 0
	fi
}

ser = $(echo -e "scripts\ndocuments\nnotes\npictures\nsuckless\nconfig" | dmenu -i -p Server: -l 10)
exit_justify "$ser"

loc = $(echo -e "scripts\ndocuments\nnotes\npictures\nsrc\n.config" | dmenu -i -p Local: -l 10)
exit_justify "$loc"

nextcloudcmd --path $ser ~/$loc ownclouds://tianyinmath.xyz/nextcloud

