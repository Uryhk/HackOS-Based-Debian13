#!/usr/bin/env bash
# hackOS :: 05-wm-i3 -- i3 en mosaico, tema y atajos coherentes con hackOS
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$HACKOS_DIR/lib/common.sh"
log_module "05-wm-i3"

apt-get install -y --no-install-recommends \
    i3 i3status i3lock rofi sakura picom dunst feh

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/i3" "$HOME_DIR/.config/i3status" \
        "$HOME_DIR/.config/picom" "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"

    cp "$HACKOS_DIR/configs/i3/config" "$HOME_DIR/.config/i3/config"
    apply_browser_placeholder "$HOME_DIR/.config/i3/config"
    cp "$HACKOS_DIR/configs/i3/i3status.conf" "$HOME_DIR/.config/i3status/config"
    cp "$HACKOS_DIR/configs/picom/picom.conf" "$HOME_DIR/.config/picom/picom.conf"
    cp "$HACKOS_DIR/configs/dunst/dunstrc" "$HOME_DIR/.config/dunst/dunstrc"
    cp "$HACKOS_DIR/configs/sakura/sakura.conf" "$HOME_DIR/.config/sakura/sakura.conf"

    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config/i3" "$HOME_DIR/.config/i3status" \
        "$HOME_DIR/.config/picom" "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"
done

ok_module "05-wm-i3"
