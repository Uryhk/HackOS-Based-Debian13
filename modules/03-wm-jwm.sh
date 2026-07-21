#!/usr/bin/env bash
# hackOS :: 03-wm-jwm -- JWM como gestor de ventanas alternativo liviano
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$HACKOS_DIR/lib/common.sh"
log_module "03-wm-jwm"

apt-get install -y --no-install-recommends jwm sakura picom dunst feh

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    install -d "$HOME_DIR/.config/picom" "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"

    cp "$HACKOS_DIR/configs/jwm/jwmrc" "$HOME_DIR/.jwmrc"
    apply_browser_placeholder "$HOME_DIR/.jwmrc"
    cp "$HACKOS_DIR/configs/picom/picom.conf" "$HOME_DIR/.config/picom/picom.conf"
    cp "$HACKOS_DIR/configs/dunst/dunstrc" "$HOME_DIR/.config/dunst/dunstrc"
    cp "$HACKOS_DIR/configs/sakura/sakura.conf" "$HOME_DIR/.config/sakura/sakura.conf"

    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.jwmrc" "$HOME_DIR/.config/picom" \
        "$HOME_DIR/.config/dunst" "$HOME_DIR/.config/sakura"
done

cat > /usr/share/xsessions/jwm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (JWM)
Comment=Sesion JWM personalizada de hackOS
Exec=jwm
TryExec=jwm
Type=Application
DesktopNames=JWM
EOF

ok_module "03-wm-jwm"
