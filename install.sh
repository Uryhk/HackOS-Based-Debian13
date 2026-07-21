#!/usr/bin/env bash
#
# hackOS installer — convierte un Debian 13 (stable) "limpio" en hackOS:
#   una distro liviana, endurecida en seguridad/privacidad, inspirada en
#   Whonix/Kicksecure, con IceWM como escritorio por defecto y JWM/cwm/i3
#   como alternativas. Terminal por defecto: Sakura.
#
# Uso:
#   sudo bash install.sh
#
set -euo pipefail

HACKOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HACKOS_DIR
LOG_FILE="/var/log/hackos-install.log"
export LOG_FILE

# ---------------------------------------------------------------------------
# Librería común (logging, checks, run_module, etc.)
# ---------------------------------------------------------------------------
if [[ ! -f "$HACKOS_DIR/lib/common.sh" ]]; then
    echo "[hackOS] No encuentro lib/common.sh junto a install.sh (HACKOS_DIR=$HACKOS_DIR)." >&2
    echo "[hackOS] Corré el script desde adentro de la carpeta hackOS/ completa: cd hackOS && sudo bash install.sh" >&2
    exit 1
fi
source "$HACKOS_DIR/lib/common.sh"

# ---------------------------------------------------------------------------
ask_browser_choice() {
    local choice
    choice=$(whiptail --title "hackOS installer" --radiolist \
        "¿Qué navegador querés? (uno solo, para no duplicar peso — se usa en todos los WM)" 12 74 2 \
        "librewolf" "LibreWolf — Firefox endurecido, paquete .deb liviano"   ON  \
        "mullvad"   "Mullvad Browser — anti-fingerprinting, vía Flatpak"     OFF \
        3>&1 1>&2 2>&3) || choice="librewolf"
    export HACKOS_BROWSER="$choice"
}

# ---------------------------------------------------------------------------
# Menú principal
# ---------------------------------------------------------------------------
main_menu() {
    SELECTIONS=$(whiptail --title "hackOS installer" --checklist \
        "Elegí los componentes a instalar (barra espaciadora para marcar):" 28 82 18 \
        "base"        "Sistema base + kernel endurecido + hardening (RECOMENDADO)"   ON  \
        "icewm"       "IceWM — escritorio por defecto, bonito y liviano"             ON  \
        "jwm"         "JWM — alternativa ultraliviana"                              ON  \
        "cwm"         "cwm (OpenBSD) — stacking minimalista, sin decoraciones"       ON  \
        "i3"          "i3 — tiling en mosaico, para usuarios avanzados"              ON  \
        "ly"          "ly login manager — modo Matrix (lluvia de caracteres)"        ON  \
        "regreet"     "Alternativa a ly: greetd+regreet (avatar real + wallpaper)"   OFF \
        "apps"        "Apps base: pcmanfm, Pluma, sakura, rofi, flatpak"             ON  \
        "browser"     "Navegador (el que elegiste) + ProtonVPN"                      ON  \
        "privacy"     "Tor, DNS cifrado, MAC random, torify-toggle"                  ON  \
        "audit"       "lynis, rkhunter, chkrootkit, auditoría semanal"               ON  \
        "fastfetch"   "fastfetch con logo hackOS en cada terminal"                   ON  \
        "nomad"       "Project N.O.M.A.D — offline survival (pesado, Docker)"        OFF \
        "branding"    "Íconos, wallpapers, logo hackOS y boot splash Plymouth"       ON  \
        "essentials"  "Ofimática, Bluetooth, WiFi, multimedia, impresión"            ON  \
        3>&1 1>&2 2>&3) || { log "Instalación cancelada por el usuario."; exit 0; }

    for sel in $SELECTIONS; do
        sel=$(echo "$sel" | tr -d '"')
        case "$sel" in
            base)       run_module "01-base.sh" ;;
            icewm)      run_module "02-wm-icewm.sh" ;;
            jwm)        run_module "03-wm-jwm.sh" ;;
            cwm)        run_module "04-wm-cwm.sh" ;;
            i3)         run_module "05-wm-i3.sh" ;;
            ly)         run_module "06-ly.sh" ;;
            regreet)    run_module "06b-regreet-avatar.sh" ;;
            apps)       run_module "07-apps.sh" ;;
            browser)    run_module "08-browser.sh" ;;
            privacy)    run_module "09-privacy-tor.sh" ;;
            audit)      run_module "10-audit.sh" ;;
            fastfetch)  run_module "11-fastfetch.sh" ;;
            nomad)      run_module "12-nomad.sh" ;;
            branding)   run_module "13-branding.sh" ;;
            essentials) run_module "14-essentials.sh" ;;
        esac
    done
}

# ---------------------------------------------------------------------------
main() {
    require_root
    touch "$LOG_FILE"
    log "=== hackOS installer iniciado ==="
    check_modules_dir
    check_debian
    ensure_dialog
    ask_browser_choice
    main_menu
    ok "Instalación de hackOS finalizada. Reiniciá el sistema para aplicar todos los cambios."
    log "Log completo en: $LOG_FILE"
}

main "$@"
