#!/usr/bin/env bash
# hackOS :: 02-wm-icewm — IceWM como escritorio por defecto
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends \
    icewm icewm-common xterm feh picom nitrogen \
    lxappearance network-manager-gnome pasystray \
    volumeicon-alsa xfce4-power-manager

for HOME_DIR in /root /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    [[ "$USER_NAME" == "root" ]] && continue  # copiamos solo a usuarios reales por defecto

    install -d "$HOME_DIR/.icewm"
    cp -r "$HACKOS_DIR/configs/icewm/." "$HOME_DIR/.icewm/"
    install -d "$HOME_DIR/Pictures/hackos-wallpapers"
    cp -r "$HACKOS_DIR/configs/wallpapers/." "$HOME_DIR/Pictures/hackos-wallpapers/" 2>/dev/null || true
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.icewm" "$HOME_DIR/Pictures/hackos-wallpapers" 2>/dev/null || true
done

# Sesión disponible en el login manager
cat > /usr/share/xsessions/icewm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (IceWM)
Comment=Sesión IceWM personalizada de hackOS
Exec=icewm-session
TryExec=icewm-session
Type=Application
DesktopNames=ICEWM
EOF

echo "[hackOS] IceWM instalado y configurado como escritorio por defecto."
