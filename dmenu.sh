#!/bin/bash
export QT_QPA_PLATFORMTHEME="qt5ct"
stest -flx /usr/bin/ /usr/local/bin | dmenu -l 20 -p 'Execute|' -x 220 -y 400 -z 2120 | /bin/zsh &
#dmenu_run -l 10 -p Run: -fn "Agave Nerd Font:size=18" -x 500 -y 500 -w 1500 -nb "#202020" -nf "#bbbbbb" -sb "#ffffff" -sf "#222222"
