#!/usr/bin/env bash
# Void Base -> zsh + bspwm/dmenu + Chinese + Codex/Mihomo + Danus/Rethlas + VimTeX/Zathura
# Prepared 2026-10-20. Run --help first. This script does not run AI jobs.
# Sources:
# https://docs.voidlinux.org/config/graphical-session/xorg.html
# https://docs.voidlinux.org/config/locales.html
# https://docs.voidlinux.org/config/services/index.html
# https://github.com/baskerville/bspwm
# https://github.com/baskerville/sxhkd
# https://fcitx-im.org/wiki/Setup_Fcitx_5
# https://developers.openai.com/codex/cli/
# https://github.com/MetaCubeX/mihomo/releases/tag/v1.19.32
# https://github.com/frenzymath/Danus/tree/codex
# https://github.com/frenzymath/Rethlas
# https://github.com/lervag/vimtex/tree/v2.17
# https://pwmt.org/projects/zathura/
# https://docs.voidlinux.org/config/texlive.html
# https://github.com/naelstrof/maim
set -Eeuo pipefail
umask 022
trap 'printf "ERROR: step failed at line %s. Fix the error above, then rerun the same step.\n" "$LINENO" >&2' ERR

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
note() { printf '\n[void-ai] %s\n' "$*"; }
need() { command -v "$1" >/dev/null || die "Missing command: $1. Run the system step first."; }
user_only() { (( EUID != 0 )) || die 'Run this step as your normal user, without sudo.'; }
void_only() { need xbps-install; need xbps-query; }
save_new() {
  local dest=$1
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    cat >/dev/null
    note "Kept existing file: $dest"
  else
    cat >"$dest"
  fi
}
help_text() {
cat <<'HELP'
Void Linux Base 安装脚本（x86_64 / aarch64；glibc 或 musl）

请在已安装的 Void 系统上操作，不要在安装 U 盘 / Live 系统上运行。
先确保网络、DNS、系统时间正常，并已创建普通用户。
系统步骤会执行完整 XBPS 更新，安装软件并启用 dbus/elogind。
不会切换现有网络管理方式，不会自动重启，不安装完整桌面环境。

一键安装（普通用户运行；需要 sudo；TeX Live 占用数 GB）：
  bash void-ai-setup.sh all /绝对路径/你的Clash配置.yaml
没有配置文件也可运行 all，之后单独导入节点。首次下载需要可用网络。
中途失败可按下面的子命令继续；已有配置默认保留。

在原电脑打包 nvim / tmux / zsh 配置（macOS / Linux，需 Python 3）：
  bash void-ai-setup.sh export-config
  bash void-ai-setup.sh export-config /压缩包输出目录
打包不会修改原文件，也不会自动上传。上传生成的 .tar.gz 后才能按本机适配。
压缩包可能包含配置中手写的密钥；分享前请检查，不要提交到公开仓库。
当前脚本提供基础配置，并不冒充已读取你的个人配置。

也可以分步依次执行：
  sudo bash void-ai-setup.sh system
  bash void-ai-setup.sh desktop
  bash void-ai-setup.sh proxy-install
  bash void-ai-setup.sh proxy-import /绝对路径/你的Clash配置.yaml
  bash void-ai-setup.sh proxy-start
  source ~/.config/void-ai/env.sh
  proxy_on
  bash void-ai-setup.sh ai
  sudo bash void-ai-setup.sh latex-system
  bash void-ai-setup.sh latex

没有 sudo：先 su - 进入 root，执行 bash /脚本绝对路径 system，
再 exit 回到普通用户执行其余步骤。system 不依赖 sudo。

默认 shell：
  system 安装 zsh；desktop 最后为当前普通用户执行 chsh 切换到 zsh。
  chsh 可能要求输入当前用户密码。退出登录再登录后生效。
  已运行过旧版脚本时，补装 zsh，再单独执行：
    sudo xbps-install -S zsh
    bash void-ai-setup.sh shell
  保留原有 .zshrc，只补充代理环境的加载；支持当前 ZDOTDIR 设置。
  不安装 Oh My Zsh 或主题。安装脚本仍用 bash 执行。
  已有 tmux 会话继续使用原 shell；新登录后新建会话使用新的默认 shell，
  除非你的 tmux 配置显式指定了其他 default-shell。

下载 Mihomo / npm / GitHub 需要可用网络。首次下载若不可达，先用
临时可用网络，或在另一台设备下载对应官方 .gz 文件并传入：
  MIHOMO_ARCHIVE=/绝对路径/mihomo-linux-amd64-compatible-v1.19.32.gz \
    bash void-ai-setup.sh proxy-install
离线包也必须通过脚本内的 SHA-256 校验。

开始使用：
  退出登录再登录（系统刚更新内核时建议重启），然后 startx
  Win+Enter 打开 Alacritty；Win+d 打开 dmenu 启动器；Win+Shift+q 关窗口
  Win+数字 切工作区；Win+Shift+数字 移动窗口；Win+Shift+e 直接退出
  Win+h/j/k/l 切窗口；Win+f 全屏；Win+m 单窗/平铺；Ctrl+Space 拼音
  窗口配置 ~/.config/bspwm/bspwmrc；快捷键 ~/.config/sxhkd/sxhkdrc
  默认没有状态栏，登录后黑色空背景是正常的，按 Win+Enter 开终端。
  若拼音未显示：fcitx5-configtool -> 添加 Pinyin（取消仅当前语言）
  中文支持针对图形终端 / 应用；纯 Linux TTY 通常不能显示汉字。
  英文界面 + UTF-8 默认保留；需要中文界面可在 ~/.xinitrc 里改 LANG。

中文与截图（新版 system + desktop 已包含）：
  中文字体 Noto CJK；输入法 Fcitx5 拼音，Ctrl+Space 切换。
  截图工具 maim：Print 框选，Shift+Print 全屏；Esc 取消框选。
  PNG 保存在 ~/Pictures/Screenshots/，同时复制到图形剪贴板。
  不支持图片粘贴的应用无法粘贴 PNG，可直接选择保存的文件。
  已装旧版环境时补装：
    sudo bash void-ai-setup.sh extras-system
    bash void-ai-setup.sh extras
  extras 保留已有配置；若已有 Print 快捷键，新增映射写入
  ~/.config/sxhkd/void-ai-screenshots.conf 供你合并，避免重复抢占。
  字体/输入法配置后重新登录图形会话；已有 Fcitx 配置不覆盖。

Clash / Mihomo：
  使用服务商导出的完整 Clash/Mihomo YAML，不是订阅 URL 或 Base64 文本。
  导入会关闭 TUN/内置 DNS/额外监听和控制接口，保留节点、分组与
  分流规则；使用系统 DNS。原文件不变，不适合依赖特殊 DNS 的配置。
  本机 mixed 端口固定为 127.0.0.1:7890；不启用 TUN 或全系统接管。
  proxy_on / proxy_off 只影响当前 shell 和随后启动的子进程。
  sudo 可能清除代理环境；浏览器需另设 HTTP/SOCKS 代理。
  不自动开机启动；每次开机运行 clash-start，再 proxy_on。
  clash-status / clash-stop；日志 ~/.local/state/void-ai/mihomo.log
  查看日志时注意其中可能包含服务商信息，不要公开上传。
  代理启动成功只代表进程已运行，不代表节点一定能访问目标网站。

Codex：
  codex --version
  codex login --device-auth
  mkdir -p ~/work/math
  cd ~/work/math
  codex
  如果账号不支持设备码登录，使用 codex login 的浏览器登录流程。
  需要本机浏览器时，可另行安装：sudo xbps-install -S firefox

Danus（安装到 ~/ai-math/Danus，codex 分支）：
  cd ~/ai-math/Danus
  编辑 config/danus.env 和 config/codex.env 选择认证方式及可用模型。
  API 模式：填入自己的 endpoint/key，然后 bash scripts/setup-codex.sh api
  ChatGPT 模式：在 config/danus.env 添加 CODEX_BACKEND=chatgpt，
              再 bash scripts/setup-codex.sh login
  bash scripts/doctor.sh
  bash scripts/services.sh up verify
  ./bin/codex
  Danus 有独立的认证目录，普通 codex 登录不等于 Danus 已登录。
  安装不填密钥、不运行模型、不启动数学任务。PDF/LaTeX 渲染的额外
  依赖按 doctor 的结果补装；这里安装的是推理运行环境。

Rethlas（安装到 ~/ai-math/Rethlas）：
  终端一：
    cd ~/ai-math/Rethlas/agents/verification
    source .venv/bin/activate
    uvicorn api.server:app --host 127.0.0.1 --port 8091
  终端二：
    cd ~/ai-math/Rethlas/agents/generation
    source .venv/bin/activate
    DRY_RUN=1 ./tests/run_example.sh
  Danus 与 Rethlas 默认都用 8091，不能同时启动这两个验证服务。
  要实际运行 Rethlas 示例，去掉 DRY_RUN=1 并设置 MAX_ITERATIONS=1。
  上游 Rethlas runner 自动使用 Codex 的无沙箱模式，Danus 上游也
  推荐此模式；实际自主运行请用隔离账户/机器，先读各项目安全说明。
  默认模型来自项目自身配置；若无权限，修改项目配置后再运行。

Neovim + LaTeX + Zathura：
  已装好前面的环境时，只需补装：
    sudo bash void-ai-setup.sh latex-system
    bash void-ai-setup.sh latex
  此步骤选择 XBPS 管理的 TeX Live，不混用 /opt 下的 tlmgr 安装。
  TeX Live 宏包和字体下载较大，请预留数 GB 空间，以 XBPS 显示为准。
  VimTeX 固定 v2.17，要求 Neovim >= 0.10，使用原生 pack/start 加载。
  已有 init.lua/init.vim 保留；添加 plugin/void-ai-latex.vim。
  如果已有其他插件管理器安装的 VimTeX，请不要重复安装，按其机制配置。
  如果自定义配置设置了 noloadplugins，需自行启用插件加载。
  图形界面中打开演示：nvim ~/work/latex-demo/main.tex
  普通模式按反斜杠再按 ll（\ll）启动/停止持续编译，然后 :w 保存。
  \lv 打开 PDF / 跳到光标对应位置；\le 查看编译错误。
  :VimtexCompile / :VimtexView 是不依赖快捷键的对应命令。
  Zathura 由 VimTeX 打开时配置反向搜索；通常 Ctrl+左键返回源码。
  如果你已有 maplocalleader，使用自己的前缀代替反斜杠。
  默认用 pdfLaTeX；中文文稿首行加 % !TeX program = xelatex。
  演示文件已配置 XeLaTeX、ctex 和 Fandol 字体。
  PDF 更新后 Zathura 自动刷新；这是保存后编译，不是每次按键编译。
  单独打开 PDF：zathura paper.pdf
  问题诊断：在 Neovim 中 :VimtexInfo 和 :checkhealth vimtex

可重复运行：已有用户配置不覆盖，已有仓库不自动 pull/reset。
proxy-import 会备份旧配置；proxy-install 固定安装已核对版本。
脚本会在 ai 步骤结束时输出各仓库提交号。
这份脚本做过静态检查，未在你的 Void 机器上实机验证。

其他命令：
  bash void-ai-setup.sh proxy-stop
  bash void-ai-setup.sh proxy-status
  bash void-ai-setup.sh --help
HELP
}

system_setup() {
  (( EUID == 0 )) || die 'Use sudo bash void-ai-setup.sh system, or run this step from a root shell.'
  void_only
  case "$(uname -m)" in x86_64|aarch64) ;; *) die 'This script supports x86_64 and aarch64 only.';; esac
  note 'Updating XBPS and the system. Keep the machine powered on.'
  xbps-install -Sy xbps
  xbps-install -Suy
  local packages=(
    ca-certificates curl wget git tmux neovim zsh ripgrep fd fzf jq unzip xz gzip tar
    base-devel pkg-config python3 python3-pip python3-devel python3-yaml
    openssl-devel libffi-devel nodejs
    xorg-minimal xinit xauth xf86-input-libinput mesa-dri
    bspwm sxhkd dmenu alacritty xclip maim slop xdg-utils dbus elogind procps-ng
    fcitx5 fcitx5-chinese-addons fcitx5-gtk+3 fcitx5-qt5 fcitx5-qt6 fcitx5-configtool
    noto-fonts-cjk dejavu-fonts-ttf fontconfig
  )
  local p
  for p in "${packages[@]}"; do
    xbps-query -R "$p" >/dev/null || die "Package unavailable in your repository: $p. Check mirror/architecture."
  done
  xbps-install -y "${packages[@]}"
  if xbps-query glibc >/dev/null 2>&1; then
    xbps-install -y glibc-locales
    for p in 'en_US.UTF-8 UTF-8' 'zh_CN.UTF-8 UTF-8'; do
      grep -qxF "$p" /etc/default/libc-locales || printf '%s\n' "$p" >>/etc/default/libc-locales
    done
    xbps-reconfigure -f glibc-locales
  fi
  for p in dbus elogind; do
    [[ -d /etc/sv/$p ]] || die "Missing service: /etc/sv/$p"
    if [[ ! -e /var/service/$p && ! -L /var/service/$p ]]; then
      ln -s "/etc/sv/$p" "/var/service/$p"
    fi
    sv -w 15 up "/var/service/$p"
  done
  note 'System stage complete. Run desktop as your normal user. Log out/in before startx.'
  note 'NVIDIA proprietary drivers and unusual hardware may need separate driver setup.'
}

shell_setup() {
  user_only; need zsh; need chsh; need getent
  local zsh_path user_name current_shell zsh_rc
  zsh_path=$(command -v zsh)
  grep -qxF "$zsh_path" /etc/shells || die "$zsh_path is not listed in /etc/shells. Check the zsh package installation."
  zsh_rc="${ZDOTDIR:-$HOME}/.zshrc"
  mkdir -p "$(dirname "$zsh_rc")"
  touch "$zsh_rc"
  if ! grep -qF '# void-ai environment' "$zsh_rc"; then
    cat >>"$zsh_rc" <<'ZSHRC'

# void-ai environment
[ ! -f "$HOME/.config/void-ai/env.sh" ] || . "$HOME/.config/void-ai/env.sh"
ZSHRC
  fi
  user_name=$(id -un)
  current_shell=$(getent passwd "$user_name" | cut -d: -f7)
  if [[ "$current_shell" != "$zsh_path" ]]; then
    note 'Changing your login shell to zsh. chsh may ask for your account password.'
    chsh -s "$zsh_path"
  fi
  current_shell=$(getent passwd "$user_name" | cut -d: -f7)
  [[ "$current_shell" == "$zsh_path" ]] || die 'Login shell has not changed. Check chsh output and retry the shell step.'
  note 'Default login shell is zsh. Log out and log in again to use it.'
}

desktop_setup() {
  user_only; void_only
  need bspwm; need sxhkd; need fcitx5; need alacritty
  mkdir -p "$HOME/.local/bin" "$HOME/.local/libexec" "$HOME/.config/void-ai"
  if [[ $(readlink -f "${BASH_SOURCE[0]}") != "$HOME/.local/libexec/void-ai-setup.sh" ]]; then
    install -m 755 "${BASH_SOURCE[0]}" "$HOME/.local/libexec/void-ai-setup.sh"
  fi
  save_new "$HOME/.config/void-ai/env.sh" <<'ENV'
# Source this file from bash or zsh. No proxy is enabled until proxy_on is called.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac
proxy_on() {
  export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890
  export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy"
  export all_proxy=socks5h://127.0.0.1:7890 ALL_PROXY=socks5h://127.0.0.1:7890
  export no_proxy=localhost,127.0.0.1,::1 NO_PROXY=localhost,127.0.0.1,::1
  printf 'Proxy enabled for this shell: 127.0.0.1:7890\n'
}
proxy_off() {
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY
  printf 'Proxy disabled for this shell.\n'
}
ENV
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.profile"; do
    touch "$rc"
    if ! grep -qF '# void-ai environment' "$rc"; then
      cat >>"$rc" <<'RC'

# void-ai environment
[ ! -f "$HOME/.config/void-ai/env.sh" ] || . "$HOME/.config/void-ai/env.sh"
RC
    fi
  done
  save_new "$HOME/.xinitrc" <<'XINIT'
#!/bin/sh
export PATH="$HOME/.local/bin:$PATH"
export LANG=en_US.UTF-8
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
exec dbus-run-session -- bspwm
XINIT
  save_new "$HOME/.config/bspwm/bspwmrc" <<'BSPWM'
#!/bin/sh
# bspwm reruns this file on restart. Start session helpers only at first launch.
if [ "${1:-0}" -eq 0 ]; then
    sxhkd &
    fcitx5 -d
fi
bspc monitor -d 1 2 3 4 5 6 7 8 9 10
bspc config border_width 2
bspc config window_gap 8
bspc config split_ratio 0.52
bspc config borderless_monocle true
bspc config gapless_monocle true
bspc config focus_follows_pointer true
bspc config pointer_modifier mod4
bspc config pointer_action1 move
bspc config pointer_action2 resize_side
bspc config pointer_action3 resize_corner
bspc config normal_border_color '#343b48'
bspc config active_border_color '#536079'
bspc config focused_border_color '#7aa2f7'
bspc rule -a Fcitx5-config-qt state=floating
BSPWM
  chmod 755 "$HOME/.config/bspwm/bspwmrc"
  save_new "$HOME/.config/sxhkd/sxhkdrc" <<'SXHKD'
# Terminal / launcher
super + Return
    alacritty
super + d
    dmenu_run
# Close window; quit session; restart WM; reload hotkeys
super + shift + q
    bspc node -c
super + shift + e
    bspc quit
super + shift + r
    bspc wm -r
super + Escape
    pkill -USR1 -x sxhkd
# Focus / swap in a direction
super + {h,j,k,l}
    bspc node -f {west,south,north,east}
super + shift + {h,j,k,l}
    bspc node -s {west,south,north,east}
# Workspace / move window to workspace
super + {1-9,0}
    bspc desktop -f '^{1-9,10}'
super + shift + {1-9,0}
    bspc node -d '^{1-9,10}'
# Layout and window states
super + m
    bspc desktop -l next
super + f
    bspc node -t '~fullscreen'
super + shift + space
    bspc node -t '~floating'
# Pick next split direction / cancel preselection
super + ctrl + {h,j,k,l}
    bspc node -p {west,south,north,east}
super + ctrl + space
    bspc node -p cancel
# Resize split ratio
super + bracket{left,right}
    bspc node -r {-0.05,+0.05}
SXHKD
  save_new "$HOME/.config/fcitx5/profile" <<'FCITX'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=pinyin

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=pinyin
Layout=

[GroupOrder]
0=Default
FCITX
  save_new "$HOME/.config/alacritty/alacritty.toml" <<'ALACRITTY'
[font]
size = 12.0
[font.normal]
family = "DejaVu Sans Mono"
[window.padding]
x = 6
y = 6
ALACRITTY
  local action
  for action in start stop status; do
    printf '#!/bin/sh\nexec bash "$HOME/.local/libexec/void-ai-setup.sh" proxy-%s\n' "$action" >"$HOME/.local/bin/clash-$action"
    chmod 755 "$HOME/.local/bin/clash-$action"
  done
  sh -n "$HOME/.config/bspwm/bspwmrc"
  extras_setup
  note 'Desktop ready. Existing configuration was kept; if .xinitrc already existed, integrate the bspwm/Fcitx startup manually.'
  shell_setup
  note 'Log out/in, then startx. Current terminal: source ~/.config/void-ai/env.sh'
}

extras_system_setup() {
  (( EUID == 0 )) || die 'Use sudo bash void-ai-setup.sh extras-system.'
  void_only
  xbps-install -Sy xbps
  xbps-install -Suy
  xbps-install -y noto-fonts-cjk dejavu-fonts-ttf fontconfig \
    fcitx5 fcitx5-chinese-addons fcitx5-gtk+3 fcitx5-qt5 fcitx5-qt6 fcitx5-configtool \
    maim slop xclip
  note 'Chinese fonts, input method and screenshot packages installed. Run extras as your normal user.'
}

extras_setup() {
  user_only; need fc-cache; need maim; need xclip
  save_new "$HOME/.config/fontconfig/conf.d/60-void-ai-cjk.conf" <<'FONTS'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias><family>sans-serif</family><prefer><family>Noto Sans CJK SC</family></prefer></alias>
  <alias><family>serif</family><prefer><family>Noto Serif CJK SC</family></prefer></alias>
  <alias><family>monospace</family><prefer><family>DejaVu Sans Mono</family><family>Noto Sans Mono CJK SC</family></prefer></alias>
</fontconfig>
FONTS
  fc-cache -f
  save_new "$HOME/.local/bin/void-screenshot" <<'SCREENSHOT'
#!/bin/sh
set -eu
umask 077
mode=${1:-region}
case "$mode" in region|full) ;; *) echo 'Usage: void-screenshot [region|full]' >&2; exit 2;; esac
directory="$HOME/Pictures/Screenshots"
mkdir -p "$directory"
temporary=$(mktemp "$directory/.capture.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT HUP INT TERM
case "$mode" in
  region) if ! maim -s -f png "$temporary"; then exit 1; fi;;
  full) maim -f png "$temporary";;
esac
image_path="$directory/screenshot-$(date +%Y%m%d-%H%M%S)-$$.png"
mv "$temporary" "$image_path"
xclip -selection clipboard -t image/png -i "$image_path"
printf 'Saved and copied: %s\n' "$image_path"
SCREENSHOT
  chmod 755 "$HOME/.local/bin/void-screenshot"
  local hotkeys="$HOME/.config/sxhkd/sxhkdrc" bindings="$HOME/.config/sxhkd/void-ai-screenshots.conf"
  save_new "$bindings" <<'SHOTKEYS'
# void-ai screenshot shortcuts
Print
    "$HOME/.local/bin/void-screenshot" region
shift + Print
    "$HOME/.local/bin/void-screenshot" full
SHOTKEYS
  if [[ -f "$hotkeys" ]] && ! grep -qF '# void-ai screenshot shortcuts' "$hotkeys"; then
    if grep -Eq '^[^#[:space:]].*Print|^Print([[:space:]]|$)' "$hotkeys"; then
      note "Existing Print bindings kept. Merge $bindings manually if desired."
    else
      printf '\n' >>"$hotkeys"
      cat "$bindings" >>"$hotkeys"
      if command -v pkill >/dev/null; then pkill -USR1 -u "$(id -u)" -x sxhkd || true; fi
    fi
  fi
  note 'Screenshots: Print = select region; Shift+Print = full screen; ~/Pictures/Screenshots/.'
  note 'Chinese input is configured by desktop; run desktop first if this is a fresh installation.'
}

proxy_install() (
  user_only; need curl; need sha256sum; need gzip
  local asset checksum work
  case "$(uname -m)" in
    x86_64) asset=mihomo-linux-amd64-compatible-v1.19.32.gz; checksum=ba3ce607747a07f948fc35780e108a4a7c7f552a38b9bd4d115f313ebcb89c20;;
    aarch64) asset=mihomo-linux-arm64-v1.19.32.gz; checksum=9dd862e28b46ff7d775f169cceebc28deccaa0a9e804237d421cd2571e0caba0;;
    *) die 'Unsupported architecture.';;
  esac
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  if [[ -n ${MIHOMO_ARCHIVE:-} ]]; then
    cp -- "$MIHOMO_ARCHIVE" "$work/core.gz"
  else
    curl -fL --retry 3 --connect-timeout 20 --max-time 600 \
      "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.32/$asset" -o "$work/core.gz"
  fi
  printf '%s  %s\n' "$checksum" "$work/core.gz" | sha256sum -c -
  gzip -dc "$work/core.gz" >"$work/mihomo"
  chmod 755 "$work/mihomo"
  "$work/mihomo" -v
  mkdir -p "$HOME/.local/bin"
  install -m 755 "$work/mihomo" "$HOME/.local/bin/mihomo"
  note 'Mihomo installed. Next: proxy-import /path/to/config.yaml'
)

proxy_import() (
  user_only; need python3
  [[ $# == 1 && -f $1 ]] || die 'Usage: proxy-import /path/to/full-clash-config.yaml'
  [[ -x "$HOME/.local/bin/mihomo" ]] || die 'Run proxy-install first.'
  local cfg="$HOME/.config/mihomo" state="$HOME/.local/state/void-ai" temp
  mkdir -p "$cfg" "$state"
  chmod 700 "$cfg" "$state"
  temp=$(mktemp "$cfg/.import.XXXXXX")
  trap 'rm -f -- "$temp"' EXIT
  python3 - "$1" "$temp" <<'PY'
import sys, yaml
with open(sys.argv[1], encoding='utf-8-sig') as f:
    c = yaml.safe_load(f)
if not isinstance(c, dict) or not (c.get('proxies') or c.get('proxy-providers')) or not c.get('rules'):
    raise SystemExit('Please supply a complete Clash/Mihomo config with nodes/providers and rules.')
# Local explicit proxy only. Retain outbound nodes/groups/rules.
for key in ('listeners', 'tunnels', 'external-controller-unix', 'external-controller-pipe',
            'external-controller-tls', 'external-ui', 'external-ui-url', 'external-ui-name'):
    c.pop(key, None)
c.update({'mixed-port':7890, 'port':0, 'socks-port':0, 'redir-port':0,
          'tproxy-port':0, 'allow-lan':False, 'bind-address':'127.0.0.1',
          'external-controller':'', 'authentication':[], 'mode':'rule',
          'tun':{'enable':False}, 'dns':{'enable':False}})
with open(sys.argv[2], 'w', encoding='utf-8') as f:
    yaml.safe_dump(c, f, allow_unicode=True, sort_keys=False)
PY
  if ! "$HOME/.local/bin/mihomo" -t -d "$cfg" -f "$temp" >"$state/config-check.log" 2>&1; then
    die "Config validation failed; old config kept. Inspect $state/config-check.log locally. Some configs need downloadable rule/GEO data."
  fi
  if [[ -f "$cfg/config.yaml" ]]; then
    cp -p "$cfg/config.yaml" "$cfg/config.yaml.bak.$(date +%Y%m%d-%H%M%S).$$"
  fi
  chmod 600 "$temp"
  mv "$temp" "$cfg/config.yaml"
  note 'Configuration imported. If Mihomo is already running, proxy-stop then proxy-start.'
)

proxy_start() {
  user_only; need tmux; need python3
  local cfg="$HOME/.config/mihomo" state="$HOME/.local/state/void-ai"
  [[ -s "$cfg/config.yaml" && -x "$HOME/.local/bin/mihomo" ]] || die 'Run proxy-install and proxy-import first.'
  if tmux has-session -t '=void-ai-mihomo' 2>/dev/null; then
    note 'Mihomo tmux session already exists. Use proxy-status.'; return
  fi
  python3 - <<'PY'
import socket
with socket.socket() as s:
    try: s.bind(('127.0.0.1',7890))
    except OSError: raise SystemExit('Port 7890 is already in use; refusing to launch a second proxy.')
PY
  mkdir -p "$state"
  chmod 700 "$state"
  # Literal shell string; paths are expanded by the child shell, never interpolated as code.
  tmux new-session -d -s void-ai-mihomo \
    'exec "$HOME/.local/bin/mihomo" -d "$HOME/.config/mihomo" >>"$HOME/.local/state/void-ai/mihomo.log" 2>&1'
  python3 - <<'PY'
import socket, time, subprocess
for _ in range(30):
    if subprocess.run(['tmux','has-session','-t','=void-ai-mihomo'],capture_output=True).returncode:
        raise SystemExit('Mihomo exited. Inspect ~/.local/state/void-ai/mihomo.log')
    try:
        with socket.create_connection(('127.0.0.1',7890),timeout=.3): break
    except OSError: time.sleep(.5)
else: raise SystemExit('No local proxy listener after 15 seconds. Check Mihomo log.')
PY
  note 'Mihomo is listening. Run: source ~/.config/void-ai/env.sh; proxy_on'
}

clone_once() {
  local repo=$1 dest=$2 branch=$3
  if [[ -e "$dest" ]]; then
    [[ -d "$dest/.git" ]] || die "$dest exists but is not a Git checkout. Move it or choose another location."
    local origin current
    origin=$(git -C "$dest" remote get-url origin)
    current=$(git -C "$dest" branch --show-current)
    [[ "$origin" == "$repo" && "$current" == "$branch" ]] || die "$dest has a different origin or branch; refusing to change it."
    note "Keeping existing checkout: $dest"
  else
    git clone --depth 1 --branch "$branch" "$repo" "$dest"
  fi
}

latex_system_setup() {
  (( EUID == 0 )) || die 'Use sudo bash void-ai-setup.sh latex-system.'
  void_only
  if xbps-query texlive-bin >/dev/null 2>&1; then
    die 'An upstream /opt TeX Live (texlive-bin) installation is present. Keep one TeX distribution; review before adding XBPS texlive.'
  fi
  note 'Installing XBPS-managed TeX Live and Zathura. TeX fonts/macros require substantial disk space.'
  xbps-install -Sy xbps
  xbps-install -Suy
  local packages=(neovim git zathura xdotool texlive texlive-XeTeX texlive-BibTeX texlive-latexmk noto-fonts-cjk)
  # Keep a previously installed PDF backend; the two backends conflict.
  if ! xbps-query zathura-pdf-poppler >/dev/null 2>&1; then
    packages+=(zathura-pdf-mupdf)
  fi
  local p
  for p in "${packages[@]}"; do
    xbps-query -R "$p" >/dev/null || die "Package unavailable: $p. Check your repository."
  done
  xbps-install -y "${packages[@]}"
  /usr/bin/latexmk -v
  /usr/bin/xelatex --version
  /usr/bin/kpsewhich ctexart.cls >/dev/null || die 'ctexart.cls is missing from TeX Live.'
  note 'LaTeX system packages ready. Run the latex step as your normal user.'
}

latex_setup() {
  user_only; need nvim; need git; need latexmk; need xelatex; need zathura
  nvim --headless -u NONE '+lua if vim.fn.has("nvim-0.10") == 0 then vim.cmd("cquit 1") end' +qa
  local data config plugin
  data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
  config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  [[ -z ${NVIM_APPNAME:-} || ${NVIM_APPNAME} == nvim ]] || die 'This setup targets the default nvim configuration; unset NVIM_APPNAME first.'
  plugin="$data/site/pack/void-ai/start/vimtex"
  mkdir -p "$(dirname "$plugin")" "$config/plugin"
  if [[ -e "$plugin" ]]; then
    [[ -d "$plugin/.git" ]] || die "Existing non-Git plugin directory: $plugin"
    [[ $(git -C "$plugin" remote get-url origin) == https://github.com/lervag/vimtex.git ]] || die 'Existing VimTeX checkout has a different origin.'
    note 'Keeping the existing VimTeX checkout.'
  else
    git clone --depth 1 --branch v2.17 https://github.com/lervag/vimtex.git "$plugin"
  fi
  save_new "$config/plugin/void-ai-latex.vim" <<'VIMTEX'
" LaTeX settings; loaded at startup so inverse-search commands are available.
" Keep any existing localleader. The Vim default is backslash.
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_quickfix_mode = 0
" Prepend the native package so its tex ftplugin precedes the bundled one.
execute 'set runtimepath^=' . fnameescape(stdpath('data') . '/site/pack/void-ai/start/vimtex')
filetype plugin indent on
syntax enable
augroup void_ai_latex
  autocmd!
  autocmd FileType tex setlocal number expandtab shiftwidth=2 softtabstop=2
augroup END
VIMTEX
  # No hardcoded inverse-search command: VimTeX sets Zathura's -x per session.
  save_new "${XDG_CONFIG_HOME:-$HOME/.config}/zathura/zathurarc" <<'ZATHURA'
set selection-clipboard clipboard
set adjust-open width
set font "DejaVu Sans Mono 11"
ZATHURA
  save_new "$HOME/work/latex-demo/main.tex" <<'LATEX'
% !TeX program = xelatex
\documentclass[UTF8,fontset=fandol]{ctexart}
\usepackage{amsmath,amssymb,amsthm}
\usepackage{hyperref}
\newtheorem{theorem}{定理}
\title{Neovim 与 Zathura 工作流}
\author{}
\date{}
\begin{document}
\maketitle
保存文件后，latexmk 编译，Zathura 自动更新 PDF。
\begin{theorem}
若闭黎曼流形上的光滑函数 $u$ 满足 $\Delta u=0$，
则 $u$ 在每个连通分支上为常数。
\end{theorem}
\begin{proof}
分部积分给出
\[
  \int_M |\nabla u|^2\,d\mu
  = -\int_M u\Delta u\,d\mu = 0.
\]
因此 $\nabla u=0$。
\end{proof}
\end{document}
LATEX
  VIMTEX_DOC_DIR="$plugin/doc" nvim --headless -u NONE \
    '+lua vim.cmd("helptags " .. vim.fn.fnameescape(vim.env.VIMTEX_DOC_DIR))' +qa
  note 'VimTeX configured. In bspwm: nvim ~/work/latex-demo/main.tex'
  note 'Normal mode: backslash ll = compile; backslash lv = view; :w = save.'
  note 'For a compile check: cd ~/work/latex-demo && latexmk -xelatex -synctex=1 -interaction=nonstopmode -halt-on-error main.tex'
}

ai_setup() {
  user_only; need npm; need python3; need git
  export PATH="$HOME/.local/bin:$PATH"
  local root="$HOME/ai-math" danus rethlas venv codex_js
  # Upstream runtime scripts contain unquoted generated paths; fail explicitly.
  [[ "$root" != *[[:space:]]* ]] || die 'AI project paths must not contain whitespace for upstream compatibility.'
  python3 -c 'import sys; assert sys.version_info >= (3,10), "Python >= 3.10 required"'
  node -e 'if (Number(process.versions.node.split(".")[0]) < 22) process.exit(1)'
  mkdir -p "$root" "$HOME/.local/bin"
  npm install -g --prefix "$HOME/.local" @openai/codex
  "$HOME/.local/bin/codex" --version
  danus="$root/Danus"; rethlas="$root/Rethlas"
  clone_once https://github.com/frenzymath/Danus.git "$danus" codex
  clone_once https://github.com/frenzymath/Rethlas.git "$rethlas" main
  [[ -f "$danus/pyproject.toml" && -f "$danus/scripts/env.sh" && -f "$danus/bin/codex" ]] || die 'Danus layout changed. Review upstream instructions.'
  note 'Installing Danus runtime using Void Python and Node (works around upstream glibc Node download).'
  venv="$danus/runtime/venv"
  mkdir -p "$danus/runtime/logs"
  [[ -d "$venv" ]] || python3 -m venv "$venv"
  "$venv/bin/python" -m pip install --upgrade pip
  "$venv/bin/python" -m pip install -e "${danus}[gateway,verify,observability,write-paper,human-summary]" 'openai>=2.40' 'anthropic>=0.92'
  "$venv/bin/python" -c 'from danus._mcp import FastMCP; import fastapi,uvicorn,pydantic,openai,anthropic'
  codex_js="$HOME/.local/lib/node_modules/@openai/codex/bin/codex.js"
  [[ -f "$codex_js" ]] || die 'Codex npm layout changed; cannot configure Danus runtime automatically.'
  if [[ -f "$danus/runtime/runtime.env" ]]; then
    cp -p "$danus/runtime/runtime.env" "$danus/runtime/runtime.env.bak.$(date +%Y%m%d-%H%M%S).$$"
  fi
  {
    printf '# Generated by void-ai-setup; use Void-managed Node.\n'
    printf 'export DANUS_NODE=%q\n' "$(command -v node)"
    printf 'export DANUS_NODE_BIN=%q\n' "$(dirname "$(command -v node)")"
    printf 'export DANUS_CODEX_JS=%q\n' "$codex_js"
    printf 'export DANUS_VENV=%q\n' "$venv"
  } >"$danus/runtime/runtime.env"
  local name
  for name in danus codex; do
    [[ -f "$danus/config/$name.env.example" ]] || die "Missing Danus template: $name.env.example"
    if [[ ! -e "$danus/config/$name.env" ]]; then
      install -m 600 "$danus/config/$name.env.example" "$danus/config/$name.env"
    fi
  done
  if [[ -f "$danus/.agents/skills/human-summary/package.json" ]]; then
    (cd "$danus/.agents/skills/human-summary"; npm install --no-fund --no-audit)
  fi
  note 'Installing Rethlas into separate Python virtual environments.'
  local part req
  for part in verification generation; do
    [[ $part == verification ]] && req=requirements.txt || req=mcp/requirements.txt
    [[ -f "$rethlas/agents/$part/$req" ]] || die "Rethlas layout changed: missing $part/$req"
    (
      cd "$rethlas/agents/$part"
      [[ -d .venv ]] || python3 -m venv .venv
      .venv/bin/python -m pip install --upgrade pip
      .venv/bin/python -m pip install -r "$req"
      .venv/bin/python -m pip check
    )
  done
  note 'AI software installed; authentication and project model configuration still required.'
  printf 'Danus commit: '; git -C "$danus" rev-parse HEAD
  printf 'Rethlas commit: '; git -C "$rethlas" rev-parse HEAD
  note 'Read: bash void-ai-setup.sh --help (Danus/Rethlas startup and authentication).'
}

export_config() {
  need python3
  python3 - "$@" <<'PYEXPORT'
import argparse
import io
import json
import os
from pathlib import Path
import platform
import shutil
import tarfile
import tempfile
from datetime import datetime
import uuid

parser = argparse.ArgumentParser(description='打包本机 Neovim / tmux / zsh 配置，不修改原文件。')
parser.add_argument('output_dir', nargs='?', default='.', help='压缩包保存目录，默认当前目录')
parser.add_argument('--source-home', type=Path, default=Path.home(), help='源用户目录，默认当前用户目录')
args = parser.parse_args()
source_home = args.source_home.expanduser().resolve()
real_home = Path.home().resolve()
use_env = source_home == real_home
config_root = Path(os.environ.get('XDG_CONFIG_HOME') or source_home / '.config') if use_env else source_home / '.config'
zsh_root = Path(os.environ.get('ZDOTDIR') or source_home) if use_env else source_home
app_name = (os.environ.get('NVIM_APPNAME') or 'nvim') if use_env else 'nvim'

candidates = [
    (config_root / app_name, 'config/nvim'),
    (source_home / '.tmux.conf', 'home/.tmux.conf'),
    (source_home / '.tmux.conf.local', 'home/.tmux.conf.local'),
    (config_root / 'tmux', 'config/tmux'),
    (source_home / '.tmux', 'home/.tmux'),
    (config_root / 'zsh', 'config/zsh'),
    (source_home / '.p10k.zsh', 'home/.p10k.zsh'),
    (source_home / '.oh-my-zsh' / 'custom', 'home/.oh-my-zsh/custom'),
    (source_home / '.zpreztorc', 'home/.zpreztorc'),
]
for name in ('.zshrc', '.zprofile', '.zshenv', '.zlogin', '.zlogout', '.p10k.zsh'):
    candidates.append((zsh_root / name, 'zsh-dotdir/' + name))
# .zshenv may set ZDOTDIR even when the collector was started from another shell.
candidates.append((source_home / '.zshenv', 'home/.zshenv'))

excluded_names = {'.git', '__pycache__', 'node_modules', '.DS_Store',
                  '.zsh_history', '.bash_history', '.env', 'auth.json',
                  '.netrwhist', 'resurrect'}
report = {'format_version': 1, 'os': platform.system(),
          'architecture': platform.machine(), 'nvim_appname': app_name,
          'source_home': str(source_home), 'zsh_dotdir': str(zsh_root),
          'included': [], 'missing': [], 'skipped': [],
          'notes': ['Configuration files are not executed or modified.',
                    'Symlink targets are copied as files/directories; cycles are skipped.',
                    'Histories, .git directories and selected caches/credential files are excluded.',
                    'Other sourced files outside these locations may need separate collection.',
                    'Neovim plugin lockfiles and tmux/zsh custom plugins are retained when inside the selected directories.',
                    'The archive is for review/migration, not automatic extraction into a home directory.']}
out_dir = Path(args.output_dir).expanduser().resolve()
out_dir.mkdir(parents=True, exist_ok=True)
filename = 'local-config-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '-' + uuid.uuid4().hex[:6] + '.tar.gz'
out_path = out_dir / filename
fd, temporary = tempfile.mkstemp(prefix='.config-export-', suffix='.part', dir=out_dir)
os.close(fd)
count = 0
seen_archives = set()

def add_path(archive, path, arcname, ancestors=frozenset()):
    global count
    if path.name in excluded_names or path.name.startswith('.zcompdump') or path.suffix in ('.swp', '.swo', '.pyc'):
        report['skipped'].append({'path': str(path), 'reason': 'excluded cache/history/metadata'})
        return
    resolved = path.resolve(strict=True)
    if resolved in ancestors or resolved == out_path or resolved == Path(temporary):
        report['skipped'].append({'path': str(path), 'reason': 'cycle or output file'})
        return
    if arcname in seen_archives:
        return
    if path.is_dir():
        seen_archives.add(arcname)
        info = tarfile.TarInfo(arcname)
        info.type = tarfile.DIRTYPE
        info.mode = 0o700
        archive.addfile(info)
        for child in sorted(path.iterdir()):
            add_path(archive, child, arcname + '/' + child.name, ancestors | {resolved})
    elif path.is_file():
        info = archive.gettarinfo(str(path), arcname=arcname)
        info.uid = info.gid = 0
        info.uname = info.gname = ''
        info.mode = 0o700 if os.access(path, os.X_OK) else 0o600
        with path.open('rb') as stream:
            archive.addfile(info, stream)
        seen_archives.add(arcname)
        count += 1
    else:
        report['skipped'].append({'path': str(path), 'reason': 'not a regular file/directory'})

try:
    with tarfile.open(temporary, 'w:gz', dereference=True) as archive:
        for src, dest in candidates:
            if not src.exists():
                report['missing'].append(str(src))
                continue
            add_path(archive, src, 'local-config/' + dest)
            report['included'].append({'source': str(src), 'archive_path': 'local-config/' + dest})
        if not count:
            raise RuntimeError('没有找到配置文件。请在存有配置的本机、以你日常使用的账户运行。')
        report['file_count'] = count
        payload = json.dumps(report, ensure_ascii=False, indent=2).encode('utf-8')
        info = tarfile.TarInfo('local-config/MANIFEST.json')
        info.size = len(payload)
        info.mode = 0o600
        archive.addfile(info, io.BytesIO(payload))
    os.replace(temporary, out_path)
    print(f'已打包 {count} 个配置文件：\n{out_path}')
    print('请上传这个 .tar.gz 文件。原配置没有改动。')
except Exception as error:
    Path(temporary).unlink(missing_ok=True)
    raise SystemExit(f'打包失败：{error}')
PYEXPORT
}

all_setup() {
  user_only
  void_only
  (( $# <= 1 )) || die 'Usage: bash void-ai-setup.sh all [Clash.yaml]'
  local self proxy_config=${1:-}
  self=$(readlink -f "${BASH_SOURCE[0]}")
  if [[ -n "$proxy_config" ]]; then
    [[ -f "$proxy_config" && -r "$proxy_config" ]] || die "Cannot read Clash config: $proxy_config"
    proxy_config=$(readlink -f "$proxy_config")
  fi
  command -v sudo >/dev/null || die 'all requires sudo. Use su - and the separate system / latex-system steps shown in --help.'
  sudo -v
  sudo bash "$self" system
  desktop_setup
  export PATH="$HOME/.local/bin:$PATH"
  proxy_install
  if [[ -n "$proxy_config" ]]; then
    proxy_import "$proxy_config"
    proxy_start
    export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890
    export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy"
    export all_proxy=socks5h://127.0.0.1:7890 ALL_PROXY=socks5h://127.0.0.1:7890
    export no_proxy=localhost,127.0.0.1,::1 NO_PROXY=localhost,127.0.0.1,::1
  fi
  sudo bash "$self" latex-system
  latex_setup
  ai_setup
  note '安装完成。退出登录再登录，然后运行 startx。Codex / 数学工具仍需登录及模型配置，见 --help。'
  if [[ -z "$proxy_config" ]]; then
    note '尚未导入代理节点：运行 proxy-import /路径/Clash.yaml，再运行 proxy-start。'
  fi
  note '本机 nvim/tmux/zsh 个人配置尚未迁移：在原电脑运行此脚本的 export-config 子命令。'
}

case "${1:---help}" in
  all) shift; all_setup "$@";;
  export-config) shift; export_config "$@";;
  -h|--help|help) help_text;;
  system) system_setup;;
  desktop) desktop_setup;;
  shell) shell_setup;;
  extras-system) extras_system_setup;;
  extras) extras_setup;;
  latex-system) latex_system_setup;;
  latex) latex_setup;;
  proxy-install) proxy_install;;
  proxy-import) shift; proxy_import "$@";;
  proxy-start) proxy_start;;
  proxy-stop)
    user_only; need tmux
    if tmux has-session -t '=void-ai-mihomo' 2>/dev/null; then tmux kill-session -t '=void-ai-mihomo'; fi
    note 'Mihomo stopped. Run proxy_off in any shell where proxy_on was used.';;
  proxy-status)
    user_only; need tmux
    tmux has-session -t '=void-ai-mihomo' 2>/dev/null || die 'Mihomo tmux session is not running.'
    note 'Mihomo tmux session is running; log: ~/.local/state/void-ai/mihomo.log';;
  ai) ai_setup;;
  *) die "Unknown step: $1 (use --help)";;
esac
