#!/usr/bin/env bash
# hackOS :: 02-wm-icewm -- IceWM como escritorio por defecto
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$HACKOS_DIR/lib/common.sh"
log_module "02-wm-icewm"

apt-get install -y --no-install-recommends \
    icewm icewm-common sakura feh picom nitrogen \
    lxappearance network-manager-gnome pasystray \
    volumeicon-alsa xfce4-power-manager

for HOME_DIR in /root /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    [[ "$USER_NAME" == "root" ]] && continue  # copiamos solo a usuarios reales por defecto

    install -d "$HOME_DIR/.icewm"
    cp -r "$HACKOS_DIR/configs/icewm/." "$HOME_DIR/.icewm/"
    cp "$HACKOS_DIR/configs/picom/picom.conf" "$HOME_DIR/.icewm/picom.conf"
    apply_browser_placeholder "$HOME_DIR/.icewm/keys"
    apply_browser_placeholder "$HOME_DIR/.icewm/toolbar"
    install -d "$HOME_DIR/Pictures/hackos-wallpapers"
    cp -r "$HACKOS_DIR/configs/wallpapers/." "$HOME_DIR/Pictures/hackos-wallpapers/" 2>/dev/null || true
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.icewm" "$HOME_DIR/Pictures/hackos-wallpapers" 2>/dev/null || true
done

# Sesion disponible en el login manager
cat > /usr/share/xsessions/icewm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (IceWM)
Comment=Sesion IceWM personalizada de hackOS
Exec=icewm-session
TryExec=icewm-session
Type=Application
DesktopNames=ICEWM
EOF

ok_module "02-wm-icewm"
