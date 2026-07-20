#!/usr/bin/env bash
# hackOS :: 08-browser — LibreWolf + Mullvad Browser + ProtonVPN
set -euo pipefail

apt-get install -y --no-install-recommends extrepo || true
extrepo enable librewolf 2>/dev/null || true

# --- LibreWolf (repo oficial) ------------------------------------------
install -d /etc/apt/keyrings
curl -fsSL https://deb.librewolf.net/keyring.gpg -o /etc/apt/keyrings/librewolf.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/librewolf.gpg] https://deb.librewolf.net trixie main" \
    > /etc/apt/sources.list.d/librewolf.sources.list
apt-get update -qq
apt-get install -y librewolf

# --- Mullvad Browser (vía Flatpak, es la vía soportada oficialmente) -----
flatpak install -y --noninteractive flathub net.mullvad.MullvadBrowser || \
    echo "[hackOS] No se pudo instalar Mullvad Browser ahora; probá luego con: flatpak install flathub net.mullvad.MullvadBrowser"

# --- ProtonVPN (repo oficial) --------------------------------------------
PVPN_DEB="/tmp/protonvpn-stable-release.deb"
curl -fsSL "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb" -o "$PVPN_DEB" || true
if [[ -f "$PVPN_DEB" ]]; then
    dpkg -i "$PVPN_DEB" || true
    apt-get update -qq
    apt-get install -y proton-vpn-gnome-desktop || \
        echo "[hackOS] Instalá ProtonVPN manualmente si el paquete cambió: https://protonvpn.com/support/linux-vpn-tool/"
fi

echo "[hackOS] LibreWolf, Mullvad Browser y ProtonVPN instalados (o con instrucciones de fallback)."
