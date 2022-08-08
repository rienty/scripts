#!/bin/bash         

sel=$(find ~/scripts -maxdepth 20 -type f | dmenu -i -p 'Script|' -x 220 -y 220 -z 2120 -l 23 )


if [ -n "$sel" ] 
then
    bash $sel
fi


