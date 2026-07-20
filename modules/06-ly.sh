#!/usr/bin/env bash
# hackOS :: 06-ly — ly (TUI) como login manager principal, en modo MATRIX
#
# ly soporta nativamente una animacion de "lluvia" estilo Matrix como fondo
# (animation = matrix en su config.ini) — es la forma mas simple y fiel de
# lograr el efecto Matrix que pediste, sin depender de nada grafico pesado.
#
# Limitacion real (ya la charlamos): al ser TUI, ly no puede mostrar fotos
# ni un avatar circular de verdad. Si en algun momento preferis esa opcion
# en vez del efecto Matrix, instala el modulo alternativo:
#   sudo bash modules/06b-regreet-avatar.sh
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends build-essential git libpam0g-dev libxcb-xkb-dev pkg-config

if ! command -v zig >/dev/null 2>&1; then
    ZIG_VER="0.13.0"
    curl -fsSL "https://ziglang.org/download/${ZIG_VER}/zig-linux-x86_64-${ZIG_VER}.tar.xz" -o /tmp/zig.tar.xz
    tar -C /usr/local -xf /tmp/zig.tar.xz
    ln -sf "/usr/local/zig-linux-x86_64-${ZIG_VER}/zig" /usr/local/bin/zig
fi

BUILD_DIR="/usr/local/src/hackos-ly"
rm -rf "$BUILD_DIR"
git clone --recursive https://github.com/fairyglade/ly "$BUILD_DIR"
(cd "$BUILD_DIR" && zig build -Doptimize=ReleaseSafe)
install -Dm755 "$BUILD_DIR/zig-out/bin/ly" /usr/local/bin/ly

install -d /etc/ly
cp "$HACKOS_DIR/configs/ly/config.ini" /etc/ly/config.ini
cp "$BUILD_DIR/res/ly.service" /etc/systemd/system/ly.service

for dm in gdm3 lightdm sddm greetd; do
    systemctl disable "$dm" 2>/dev/null || true
done
systemctl enable ly.service
systemctl set-default graphical.target

echo "[hackOS] ly instalado como login manager principal, en modo Matrix (lluvia de caracteres)."
echo "[hackOS] Preferís foto/avatar en vez de Matrix? sudo bash modules/06b-regreet-avatar.sh"
