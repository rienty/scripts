#!/bin/bash
# 获取所有 Zathura 窗口的 ID 和标题
windows=$(bspc query -N -n .window.className=Zathura | while read -r id; do
  title=$(bspc query -T -n "$id" | jq -r '.client.title')
  # 提取纯净的文件名（移除 " - zathura" 后缀）
  filename=$(echo "$title" | sed 's/ - zathura$//')
  # 输出格式: "文件名 | 窗口ID"
  echo "$filename | $id"
done)

# 如果没有打开的 Zathura 窗口则退出
if [ -z "$windows" ]; then
  notify-send "Zathura Switcher" "No PDF files open in Zathura"
  exit 0
fi

# 通过 dmenu 选择文件
selected=$(echo "$windows" | dmenu -i -p "Go to PDF:" -l 10)

# 提取选中的窗口 ID
win_id=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)

# 聚焦选中的窗口
if [ -n "$win_id" ]; then
  bspc node -f "$win_id"
fi
