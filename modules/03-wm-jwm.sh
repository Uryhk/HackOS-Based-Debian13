#!/usr/bin/env bash
# hackOS :: 03-wm-jwm — JWM como gestor de ventanas alternativo liviano
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends jwm

for HOME_DIR in /home/*; do
    [[ -d "$HOME_DIR" ]] || continue
    USER_NAME=$(basename "$HOME_DIR")
    cp "$HACKOS_DIR/configs/jwm/jwmrc" "$HOME_DIR/.jwmrc"
    chown "$USER_NAME:$USER_NAME" "$HOME_DIR/.jwmrc"
done

cat > /usr/share/xsessions/jwm-hackos.desktop <<'EOF'
[Desktop Entry]
Name=hackOS (JWM)
Comment=Sesión JWM personalizada de hackOS
Exec=jwm
TryExec=jwm
Type=Application
DesktopNames=JWM
EOF

echo "[hackOS] JWM instalado y configurado."
