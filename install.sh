#!/usr/bin/env bash
#
# hackOS installer — convierte un Debian 13 (stable) "limpio" en hackOS:
#   una distro liviana, endurecida en seguridad/privacidad, inspirada en
#   Whonix/Kicksecure, con IceWM como escritorio por defecto y JWM/dwm/i3
#   como alternativas.
#
# Uso:
#   sudo bash install.sh
#
set -euo pipefail

HACKOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HACKOS_DIR
LOG_FILE="/var/log/hackos-install.log"

# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------
c_reset="\e[0m"; c_green="\e[1;32m"; c_red="\e[1;31m"; c_cyan="\e[1;36m"; c_yellow="\e[1;33m"

log()  { echo -e "${c_cyan}[hackOS]${c_reset} $*" | tee -a "$LOG_FILE"; }
ok()   { echo -e "${c_green}[ OK ]${c_reset} $*" | tee -a "$LOG_FILE"; }
err()  { echo -e "${c_red}[FAIL]${c_reset} $*" | tee -a "$LOG_FILE" >&2; }
warn() { echo -e "${c_yellow}[WARN]${c_reset} $*" | tee -a "$LOG_FILE"; }

require_root() {
    if [[ $EUID -ne 0 ]]; then
        err "Este instalador debe ejecutarse como root (sudo bash install.sh)."
        exit 1
    fi
}

check_debian() {
    if ! grep -qi "trixie\|13" /etc/debian_version 2>/dev/null && \
       ! grep -qi "debian" /etc/os-release 2>/dev/null; then
        warn "No se detectó Debian 13 (trixie). El script fue diseñado para eso; continúa bajo tu responsabilidad."
        read -rp "¿Continuar de todos modos? [s/N]: " ans
        [[ "${ans,,}" == "s" ]] || exit 1
    fi
}

ensure_dialog() {
    if ! command -v whiptail >/dev/null 2>&1; then
        log "Instalando whiptail (interfaz de menú)..."
        apt-get update -qq
        apt-get install -y -qq whiptail
    fi
}

run_module() {
    local module="$1"
    local path="$HACKOS_DIR/modules/$module"
    if [[ -x "$path" ]]; then
        log "Ejecutando módulo: $module"
        bash "$path" 2>&1 | tee -a "$LOG_FILE"
        ok "Módulo completado: $module"
    else
        err "Módulo no encontrado o no ejecutable: $module"
    fi
}

# ---------------------------------------------------------------------------
# Menú principal
# ---------------------------------------------------------------------------
main_menu() {
    SELECTIONS=$(whiptail --title "hackOS installer" --checklist \
        "Elegí los componentes a instalar (barra espaciadora para marcar):" 24 78 14 \
        "base"        "Sistema base + kernel endurecido + hardening (recomendado)"  ON  \
        "icewm"       "IceWM (escritorio por defecto)"                              ON  \
        "jwm"         "JWM (gestor de ventanas alternativo)"                        ON  \
        "dwm"         "dwm (compilado desde fuente, estilo suckless)"               ON  \
        "i3"          "i3 (gestor de ventanas en mosaico)"                          ON  \
        "ly"          "ly (login manager, modo Matrix — lluvia de caracteres)"     ON  \
        "apps"        "Apps base: pcmanfm, Pluma, xterm, rofi, flatpak"             ON  \
        "browser"     "LibreWolf + Mullvad Browser"                                 ON  \
        "privacy"     "Tor, ProtonVPN, capa de privacidad estilo Whonix/Kicksecure" ON  \
        "audit"       "Herramientas de auditoría: lynis, rkhunter, chkrootkit"      ON  \
        "fastfetch"   "fastfetch personalizado con branding hackOS"                 ON  \
        "nomad"       "Project N.O.M.A.D (Crosstalk-Solutions) — offline survival"  ON  \
        "branding"    "Íconos, wallpapers, logo hackOS y boot splash Plymouth"      ON  \
        3>&1 1>&2 2>&3) || { log "Instalación cancelada por el usuario."; exit 0; }


    for sel in $SELECTIONS; do
        sel=$(echo "$sel" | tr -d '"')
        case "$sel" in
            base)      run_module "01-base.sh" ;;
            icewm)     run_module "02-wm-icewm.sh" ;;
            jwm)       run_module "03-wm-jwm.sh" ;;
            dwm)       run_module "04-wm-dwm.sh" ;;
            i3)        run_module "05-wm-i3.sh" ;;
            ly)        run_module "06-ly.sh" ;;
            apps)      run_module "07-apps.sh" ;;
            browser)   run_module "08-browser.sh" ;;
            privacy)   run_module "09-privacy-tor.sh" ;;
            audit)     run_module "10-audit.sh" ;;
            fastfetch) run_module "11-fastfetch.sh" ;;
            nomad)     run_module "12-nomad.sh" ;;
            branding)  run_module "13-branding.sh" ;;
        esac
    done
}

# ---------------------------------------------------------------------------
main() {
    require_root
    touch "$LOG_FILE"
    log "=== hackOS installer iniciado ==="
    check_debian
    ensure_dialog
    main_menu
    ok "Instalación de hackOS finalizada. Reiniciá el sistema para aplicar todos los cambios."
    log "Log completo en: $LOG_FILE"
}

main "$@"
