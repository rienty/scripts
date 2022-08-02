windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)

target=$(echo "$windows" | dmenu -l 10 -i -p Switch: )

if [[ -n $target ]]; then
        wmctrl -a "$target"
fi


