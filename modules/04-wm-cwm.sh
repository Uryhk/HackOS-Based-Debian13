#!/usr/bin/env bash
# hackOS :: 04-wm-cwm -- cwm (Calm Window Manager) de OpenBSD
# WM stacking minimalista, sin decoraciones, viene empaquetado en Debian
# (no hace falta compilar como con dwm) -- config validada con 'cwm -n'.
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$HACKOS_DIR/lib/common.sh"
log_module "04-wm-cwm"

apt-get install -y --no-install-recommends cwm fonts-jetbrains-mono picom dunst feh

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/picom" "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"

    cp "$HACKOS_DIR/configs/cwm/cwmrc" "$HOME_DIR/.cwmrc"
    apply_browser_placeholder "$HOME_DIR/.cwmrc"
    cp "$HACKOS_DIR/configs/picom/picom.conf" "$HOME_DIR/.config/picom/picom.conf"
    cp "$HACKOS_DIR/configs/dunst/dunstrc" "$HOME_DIR/.config/dunst/dunstrc"
    cp "$HACKOS_DIR/configs/sakura/sakura.conf" "$HOME_DIR/.config/sakura/sakura.conf"

    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.cwmrc" "$HOME_DIR/.config/picom" \
        "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"
done

# Script de inicio para cwm (picom + dunst + wallpaper; cwm no trae nada
# de esto por su cuenta, a diferencia de IceWM/JWM/i3)
cat > /usr/local/bin/hackos-cwm-session <<'EOF'
#!/bin/sh
picom --config "$HOME/.config/picom/picom.conf" -b &
dunst &
nm-applet &

WALL_DIR="/usr/share/backgrounds/hackos"
[ -d "$WALL_DIR" ] || WALL_DIR="$HOME/Pictures/hackos-wallpapers"
if [ -d "$WALL_DIR" ] && [ "$(ls -A "$WALL_DIR" 2>/dev/null)" ]; then
    feh --bg-fill "$(find "$WALL_DIR" -type f | shuf -n1)" &
fi

exec cwm
EOF
chmod 755 /usr/local/bin/hackos-cwm-session

cat > /usr/share/xsessions/cwm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (cwm)
Comment=Sesion cwm personalizada de hackOS
Exec=/usr/local/bin/hackos-cwm-session
TryExec=/usr/local/bin/hackos-cwm-session
Type=Application
DesktopNames=CWM
EOF

ok_module "04-wm-cwm"
