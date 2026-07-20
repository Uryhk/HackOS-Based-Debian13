#!/usr/bin/env bash
# hackOS :: 06b-regreet-avatar — alternativa a ly con foto/avatar circular real
#
# NOTA TECNICA: ly (el login manager principal, 06-ly.sh) es TUI -- no puede
# mostrar fotos ni avatares circulares, solo el efecto Matrix que pediste.
# Si en algún momento preferís foto real + wallpaper de imagen en vez de
# Matrix, instalá este módulo, que reemplaza a ly por greetd + regreet
# (GTK, ~15-20MB de RAM en reposo, pero sí soporta imágenes de verdad).
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends greetd cage imagemagick

for dm in gdm3 lightdm sddm ly; do
    systemctl disable "$dm" 2>/dev/null || true
done

# --- regreet: compilar (no siempre esta empaquetado en Debian stable) ---
if ! command -v regreet >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends cargo rustc libgtk-4-dev libpango1.0-dev
    BUILD_DIR="/usr/local/src/hackos-regreet"
    rm -rf "$BUILD_DIR"
    git clone --depth 1 https://github.com/rharish101/ReGreet "$BUILD_DIR"
    (cd "$BUILD_DIR" && cargo build --release)
    install -Dm755 "$BUILD_DIR/target/release/regreet" /usr/local/bin/regreet
fi

install -d /etc/greetd /etc/hackos/theme/wallpapers /var/lib/hackos/avatars

cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "cage -s -- regreet -c /etc/greetd/regreet.toml"
user = "greeter"
EOF

cp "$HACKOS_DIR/configs/ly/regreet.toml" /etc/greetd/regreet.toml
cp "$HACKOS_DIR/configs/ly/regreet-style.css" /etc/hackos/theme/regreet-style.css
cp -r "$HACKOS_DIR/configs/wallpapers/." /etc/hackos/theme/wallpapers/ 2>/dev/null || true

if [[ -f "$HACKOS_DIR/configs/ly/default-avatar.png" ]]; then
    cp "$HACKOS_DIR/configs/ly/default-avatar.png" /var/lib/hackos/avatars/default-avatar.png
fi

cat > /usr/local/bin/hackos-set-avatar <<'EOF'
#!/usr/bin/env bash
# Uso: hackos-set-avatar /ruta/a/tu/foto.png
set -euo pipefail
[[ $# -eq 1 ]] || { echo "Uso: hackos-set-avatar <imagen>"; exit 1; }
CIRC="/tmp/hackos-avatar-circle.png"
convert "$1" -resize 200x200^ -gravity center -extent 200x200 \
    \( +clone -alpha extract -fill black -colorize 100% -fill white -draw "circle 100,100 100,0" \) \
    -alpha off -compose CopyOpacity -composite \
    "$CIRC"
install -Dm644 "$CIRC" "/var/lib/hackos/avatars/${SUDO_USER:-$USER}.png"
# regreet/accountsservice buscan el avatar acá por convención:
install -Dm644 "$CIRC" "/var/lib/AccountsService/icons/${SUDO_USER:-$USER}"
rm -f "$CIRC"
echo "Avatar circular guardado para ${SUDO_USER:-$USER}."
EOF
chmod 755 /usr/local/bin/hackos-set-avatar

install -Dm755 "$HACKOS_DIR/configs/ly/hackos-greeter-wallpaper.sh" /usr/local/bin/hackos-greeter-wallpaper
cat > /etc/systemd/system/hackos-greeter-wallpaper.service <<'EOF'
[Unit]
Description=Elige un wallpaper aleatorio para el greeter hackOS
Before=greetd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hackos-greeter-wallpaper

[Install]
WantedBy=graphical.target
EOF
systemctl enable hackos-greeter-wallpaper.service

systemctl enable greetd
systemctl set-default graphical.target

echo "[hackOS] greetd + regreet instalados: reloj, avatar circular y wallpaper intercambiable."
echo "[hackOS] Para poner tu foto: hackos-set-avatar ~/Pictures/mi-foto.jpg"
echo "[hackOS] Fondos en /etc/hackos/theme/wallpapers/ (se elige uno al azar en cada arranque)."
