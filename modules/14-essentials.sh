#!/usr/bin/env bash
# hackOS :: 14-essentials — lo que trae cualquier sistema operativo normal
# para ser usable desde el día 1: ofimática, Bluetooth, WiFi, multimedia,
# visor de PDF/imágenes, impresión, soporte de discos externos.
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export HACKOS_DIR
source "$HACKOS_DIR/lib/common.sh"

# --- Bluetooth ------------------------------------------------------------
apt-get install -y --no-install-recommends \
    bluez blueman

systemctl enable bluetooth || true

# --- WiFi (NetworkManager ya viene del módulo base; esto son las
#     herramientas de línea de comandos + firmware extra por si hace falta) -
apt-get install -y --no-install-recommends wireless-tools iw rfkill
for fw in firmware-iwlwifi firmware-realtek firmware-atheros firmware-brcm80211; do
    apt-get install -y --no-install-recommends "$fw" 2>/dev/null || \
        echo "[hackOS] $fw no disponible en tus repos (necesita el componente 'non-free-firmware' habilitado) — se puede agregar después."
done

# --- Ofimática (LibreOffice, solo los módulos más usados para no inflar
#     el consumo de disco/RAM: Writer, Calc, Impress) ----------------------
apt-get install -y --no-install-recommends \
    libreoffice-writer libreoffice-calc libreoffice-impress \
    libreoffice-gtk3 hunspell hunspell-es hunspell-en-us \
    fonts-liberation fonts-crosextra-carlito fonts-crosextra-caladea

# --- Visor de PDF liviano (zathura, no Evince que es mucho más pesado) ----
apt-get install -y --no-install-recommends \
    zathura zathura-pdf-poppler

# --- Reproductor multimedia liviano y potente ------------------------------
apt-get install -y --no-install-recommends mpv

# --- Visor de imágenes liviano ---------------------------------------------
apt-get install -y --no-install-recommends viewnior

# --- Calculadora ------------------------------------------------------------
apt-get install -y --no-install-recommends galculator

# --- Soporte de discos externos: montaje automático + sistemas de
#     archivos comunes (NTFS de Windows, exFAT de USB/SD) ------------------
apt-get install -y --no-install-recommends \
    udisks2 gvfs gvfs-backends ntfs-3g exfatprogs dosfstools

# --- Impresión (CUPS) — opcional pero es lo que trae "cualquier SO
#     normal"; si preferís no tenerlo corriendo de fondo, desactivalo con
#     'sudo systemctl disable cups' después de instalar -------------------
apt-get install -y --no-install-recommends \
    cups system-config-printer printer-driver-all
systemctl enable cups || true

echo "[hackOS] Apps esenciales instaladas: ofimática (LibreOffice Writer/Calc/Impress),"
echo "[hackOS] Bluetooth (blueman), WiFi, zathura (PDF), mpv, viewnior, galculator,"
echo "[hackOS] soporte NTFS/exFAT y CUPS (impresión)."
