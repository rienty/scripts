windows=$(wmctrl -xl | tr -s '[:blank:]' | cut -d ' ' -f 5- | sort | uniq)
pdf_w=$(echo "$windows" | grep -E ".*_.*pdf")
st_w=$(echo "$windows" | grep -vE ".*_.*pdf")
windows_m=$(echo -e "${pdf_w}\n${st_w}")
target=$(echo "$windows_m" | dmenu -l 10 -i -p 'Switch ' -x 200 -y 1000 -z 2125)

if [[ -n $target ]]; then
        wmctrl -a "$target"
fi


