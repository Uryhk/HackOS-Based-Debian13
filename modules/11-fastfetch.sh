#!/usr/bin/env bash
# hackOS :: 11-fastfetch — fastfetch personalizado con logo/branding hackOS
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends fastfetch

install -d /etc/fastfetch
cp "$HACKOS_DIR/configs/fastfetch/config.jsonc" /etc/fastfetch/config.jsonc
cp "$HACKOS_DIR/configs/fastfetch/hackos-logo.txt" /etc/fastfetch/hackos-logo.txt
cp "$HACKOS_DIR/configs/fastfetch/hackos-logo-ansi.txt" /etc/fastfetch/hackos-logo-ansi.txt

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/fastfetch"
    cp "$HACKOS_DIR/configs/fastfetch/config.jsonc" "$HOME_DIR/.config/fastfetch/config.jsonc"
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config/fastfetch"

    # Mostrar fastfetch al abrir una terminal (como el "neofetch de bienvenida")
    if ! grep -q "fastfetch" "$HOME_DIR/.bashrc" 2>/dev/null; then
        echo -e '\n# hackOS: mostrar info del sistema al abrir terminal\n[ -t 1 ] && command -v fastfetch >/dev/null && fastfetch' >> "$HOME_DIR/.bashrc"
        chown "$USER_NAME:$USER_NAME" "$HOME_DIR/.bashrc"
    fi
done

echo "[hackOS] fastfetch personalizado instalado y activado en cada terminal."
