#!/bin/bash         

sel=$(find ~/scripts -maxdepth 20 -type f | dmenu -i -p 'Script|' -x 200 -y 220 -z 2100 -l 23 )


if [ -n "$sel" ] 
then
    bash $sel
fi


