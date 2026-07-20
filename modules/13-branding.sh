#!/usr/bin/env bash
# hackOS :: 13-branding — íconos, wallpapers de sistema, logo y boot splash
#
# Instala el logo real de hackOS (el que nos diste) en las rutas estándar
# donde Linux busca íconos de app/branding, deja los wallpapers disponibles
# a nivel sistema (además de en el home de cada usuario, que ya hacen los
# módulos de cada WM), y arma un boot splash Plymouth simple: negro, logo
# centrado, spinner de puntos.
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BR="$HACKOS_DIR/configs/branding"

apt-get install -y --no-install-recommends \
    papirus-icon-theme gtk2-engines-murrine \
    plymouth plymouth-themes

# --- Íconos hicolor (para que el logo aparezca en menús, rofi, taskbar) --
for size in 16 22 24 32 48 64 128 256 512; do
    src="$BR/hackos-logo-${size}.png"
    [[ -f "$src" ]] || continue
    install -Dm644 "$src" "/usr/share/icons/hicolor/${size}x${size}/apps/hackos.png"
done
install -Dm644 "$BR/hackos-logo-256.png" /usr/share/pixmaps/hackos.png
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

# --- Tema de íconos oscuro por defecto (Papirus-Dark, coherente con el
#     resto: IceWM/JWM/dwm/i3 quedan livianos, esto es solo el set de
#     íconos que usan pcmanfm/rofi/apps) --------------------------------
install -d /etc/gtk-3.0
cat > /etc/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus-Dark
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-cursor-theme-name=Adwaita
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

# --- Wallpapers a nivel sistema (ruta estable para todos los WM/greeters) -
install -d /usr/share/backgrounds/hackos
cp -f "$HACKOS_DIR/configs/wallpapers/"*.jpg /usr/share/backgrounds/hackos/ 2>/dev/null || true
ln -sf /usr/share/backgrounds/hackos/default.jpg /usr/share/backgrounds/hackos/current.jpg 2>/dev/null || true

# --- Boot splash Plymouth: negro + logo + spinner simple -----------------
THEME_DIR="/usr/share/plymouth/themes/hackos"
install -d "$THEME_DIR"
cp "$HACKOS_DIR/configs/plymouth/hackos.plymouth" "$THEME_DIR/hackos.plymouth"
cp "$HACKOS_DIR/configs/plymouth/hackos.script" "$THEME_DIR/hackos.script"
cp "$BR/hackos-logo-256.png" "$THEME_DIR/logo.png"

if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
        "$THEME_DIR/hackos.plymouth" 100
    update-alternatives --set default.plymouth "$THEME_DIR/hackos.plymouth"
fi
update-initramfs -u 2>/dev/null || \
    echo "[hackOS] No se pudo regenerar el initramfs automáticamente; corré 'update-initramfs -u' manualmente."

echo "[hackOS] Branding instalado: íconos hicolor, Papirus-Dark, wallpapers en /usr/share/backgrounds/hackos y boot splash Plymouth."
echo "[hackOS] Si el boot splash no se ve, confirmá que 'splash' esté en GRUB_CMDLINE_LINUX_DEFAULT de /etc/default/grub y corré update-grub."
