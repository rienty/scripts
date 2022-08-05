windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)

target=$(echo "$windows" | dmenu -l 10 -i -p 'Switch ' -x 200 -y 1000 -z 2125)

if [[ -n $target ]]; then
        wmctrl -a "$target"
fi


