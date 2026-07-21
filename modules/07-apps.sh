#!/usr/bin/env bash
# hackOS :: 07-apps -- apps base livianas: pcmanfm, Pluma, sakura, rofi, flatpak
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$HACKOS_DIR/lib/common.sh"
log_module "07-apps"

apt-get install -y --no-install-recommends \
    pcmanfm gvfs gvfs-backends file-roller \
    pluma \
    sakura rofi dunst scrot xtrlock \
    fonts-jetbrains-mono fonts-noto-color-emoji \
    flatpak

# --- Flathub ---------------------------------------------------------
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- sakura + rofi por usuario --------------------------------------------
for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/sakura" "$HOME_DIR/.config/rofi"
    cp "$HACKOS_DIR/configs/sakura/sakura.conf" "$HOME_DIR/.config/sakura/sakura.conf"
    cp "$HACKOS_DIR/configs/rofi/hackos.rasi" "$HOME_DIR/.config/rofi/config.rasi"
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config/sakura" "$HOME_DIR/.config/rofi"
done

# sakura queda como terminal por defecto del sistema (x-terminal-emulator)
update-alternatives --set x-terminal-emulator /usr/bin/sakura 2>/dev/null || true

ok_module "07-apps"
