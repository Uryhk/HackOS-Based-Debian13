#!/usr/bin/env bash
# hackOS :: 08-browser -- navegador (uno solo, a eleccion) + ProtonVPN
#
# HACKOS_BROWSER controla cual se instala: "librewolf" (default) o "mullvad".
# Lo fija install.sh segun lo que elijas en el menu; si corres este modulo
# suelto sin definirlo, instala LibreWolf.
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export HACKOS_DIR
source "$HACKOS_DIR/lib/common.sh"

BROWSER_CHOICE="${HACKOS_BROWSER:-librewolf}"

case "$BROWSER_CHOICE" in
  librewolf)
    echo "[hackOS] Instalando LibreWolf..."
    apt-get install -y --no-install-recommends curl gnupg2 ca-certificates
    install -d /etc/apt/keyrings
    curl -fsSL https://deb.librewolf.net/keyring.gpg -o /etc/apt/keyrings/librewolf.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/librewolf.gpg] https://deb.librewolf.net trixie main" \
        > /etc/apt/sources.list.d/librewolf.sources.list
    apt-get update -qq
    apt-get install -y librewolf
    ;;
  mullvad)
    echo "[hackOS] Instalando Mullvad Browser (via Flatpak, via oficial soportada)..."
    apt-get install -y --no-install-recommends flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y --noninteractive flathub net.mullvad.MullvadBrowser || \
        echo "[hackOS] No se pudo instalar Mullvad Browser ahora; proba luego con: flatpak install flathub net.mullvad.MullvadBrowser"
    ;;
  *)
    echo "[hackOS] HACKOS_BROWSER='$BROWSER_CHOICE' no reconocido, instalando LibreWolf por defecto."
    apt-get install -y --no-install-recommends curl gnupg2 ca-certificates
    install -d /etc/apt/keyrings
    curl -fsSL https://deb.librewolf.net/keyring.gpg -o /etc/apt/keyrings/librewolf.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/librewolf.gpg] https://deb.librewolf.net trixie main" \
        > /etc/apt/sources.list.d/librewolf.sources.list
    apt-get update -qq
    apt-get install -y librewolf
    ;;
esac

# --- ProtonVPN (repo oficial) -- independiente del navegador elegido -----
PVPN_DEB="/tmp/protonvpn-stable-release.deb"
curl -fsSL "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb" -o "$PVPN_DEB" || true
if [[ -f "$PVPN_DEB" ]]; then
    dpkg -i "$PVPN_DEB" || true
    apt-get update -qq
    apt-get install -y proton-vpn-gnome-desktop || \
        echo "[hackOS] Instala ProtonVPN manualmente si el paquete cambio: https://protonvpn.com/support/linux-vpn-tool/"
fi

echo "[hackOS] Navegador ($BROWSER_CHOICE) + ProtonVPN instalados (o con instrucciones de fallback)."
