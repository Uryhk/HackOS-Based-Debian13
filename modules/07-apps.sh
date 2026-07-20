#!/usr/bin/env bash
# hackOS :: 07-apps — apps base livianas: pcmanfm, Pluma, xterm, rofi, flatpak
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends \
    pcmanfm gvfs gvfs-backends file-roller \
    pluma \
    xterm rofi dunst scrot xtrlock \
    fonts-jetbrains-mono fonts-noto-color-emoji \
    flatpak

# --- Flathub ---------------------------------------------------------
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- xterm "gnome-terminal-like": fuente, colores, transparencia, ---------
# scrollbar oculto por defecto, tamaño cómodo, soporte de copy/paste normal
for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    cp "$HACKOS_DIR/configs/xterm/Xresources" "$HOME_DIR/.Xresources"
    chown "$USER_NAME:$USER_NAME" "$HOME_DIR/.Xresources"
    install -d "$HOME_DIR/.config/rofi"
    cp "$HACKOS_DIR/configs/rofi/hackos.rasi" "$HOME_DIR/.config/rofi/config.rasi"
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config/rofi"
done

# xterm también hereda estos recursos a nivel sistema (usuario greeter, root, etc)
cp "$HACKOS_DIR/configs/xterm/Xresources" /etc/X11/Xresources.hackos
grep -q "Xresources.hackos" /etc/X11/Xsession.d/* 2>/dev/null || \
    echo 'xrdb -merge /etc/X11/Xresources.hackos 2>/dev/null' > /etc/X11/Xsession.d/45hackos_xresources

echo "[hackOS] pcmanfm, Pluma, xterm (estilo gnome-terminal), rofi y flatpak instalados."
