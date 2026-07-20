#!/usr/bin/env bash
# hackOS :: 05-wm-i3 — i3 en mosaico, tema y atajos coherentes con hackOS
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends \
    i3 i3status i3lock rofi

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/i3" "$HOME_DIR/.config/i3status"
    cp "$HACKOS_DIR/configs/i3/config" "$HOME_DIR/.config/i3/config"
    cp "$HACKOS_DIR/configs/i3/i3status.conf" "$HOME_DIR/.config/i3status/config"
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config/i3" "$HOME_DIR/.config/i3status"
done

echo "[hackOS] i3 instalado y configurado (sesión disponible en el login manager)."
