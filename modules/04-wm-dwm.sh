#!/usr/bin/env bash
# hackOS :: 04-wm-dwm — dwm compilado desde fuente (estilo suckless), tema hackOS
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends \
    build-essential libx11-dev libxft-dev libxinerama-dev \
    fonts-jetbrains-mono

BUILD_DIR="/usr/local/src/hackos-dwm"
rm -rf "$BUILD_DIR"
git clone --depth 1 https://git.suckless.org/dwm "$BUILD_DIR"

# Reemplazamos config.def.h por nuestro config.h ya personalizado
cp "$HACKOS_DIR/configs/dwm/config.h" "$BUILD_DIR/config.h"

# dwmblocks-like: usamos xsetroot + un script de status liviano en vez de dwmblocks
# para no tener que parchear dependencias extra.
make -C "$BUILD_DIR" clean install

install -d /usr/local/bin
install -m 755 "$HACKOS_DIR/configs/dwm/hackos-dwmstatus.sh" /usr/local/bin/hackos-dwmstatus.sh

cat > /usr/local/bin/hackos-dwm-session <<'EOF'
#!/bin/sh
hackos-dwmstatus.sh &
nm-applet &
picom -b --config "$HOME/.icewm/picom.conf" &
feh --bg-fill --randomize "$HOME/Pictures/hackos-wallpapers"/* 2>/dev/null &
exec dwm
EOF
chmod 755 /usr/local/bin/hackos-dwm-session

cat > /usr/share/xsessions/dwm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (dwm)
Comment=Sesión dwm personalizada de hackOS
Exec=/usr/local/bin/hackos-dwm-session
TryExec=/usr/local/bin/hackos-dwm-session
Type=Application
DesktopNames=DWM
EOF

echo "[hackOS] dwm compilado e instalado con configuración hackOS."
