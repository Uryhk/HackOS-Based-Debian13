#!/usr/bin/env bash
#
# hackOS :: lib/common.sh — funciones compartidas por install.sh y todos
# los módulos. Se carga con: source "$HACKOS_DIR/lib/common.sh"
#
# NOTA: este archivo NO lleva 'set -euo pipefail' propio porque lo hereda
# del script que lo importa (install.sh / cada módulo ya lo declaran).

# --- Colores de marca (paleta real extraída del logo hackOS) -------------
HACKOS_C_RESET="\e[0m"
HACKOS_C_GREEN="\e[1;32m"
HACKOS_C_RED="\e[1;31m"
HACKOS_C_CYAN="\e[1;36m"
HACKOS_C_YELLOW="\e[1;33m"
HACKOS_C_PINK="\e[1;38;5;197m"
HACKOS_C_BLUE="\e[1;38;5;81m"

HACKOS_LOG_FILE="${LOG_FILE:-/var/log/hackos-install.log}"

# --- Logging centralizado ---------------------------------------------
log()  { echo -e "${HACKOS_C_CYAN}[hackOS]${HACKOS_C_RESET} $*" | tee -a "$HACKOS_LOG_FILE"; }
ok()   { echo -e "${HACKOS_C_GREEN}[ OK ]${HACKOS_C_RESET} $*" | tee -a "$HACKOS_LOG_FILE"; }
err()  { echo -e "${HACKOS_C_RED}[FAIL]${HACKOS_C_RESET} $*" | tee -a "$HACKOS_LOG_FILE" >&2; }
warn() { echo -e "${HACKOS_C_YELLOW}[WARN]${HACKOS_C_RESET} $*" | tee -a "$HACKOS_LOG_FILE"; }

log_module() {
    echo ""
    log "═══════════════════════════════════════════════════"
    log "  MÓDULO: $1"
    log "═══════════════════════════════════════════════════"
}
log_step()   { log "  → $*"; }
ok_module()  { ok "Módulo $1 completado."; }

# --- Verificaciones básicas ------------------------------------------------
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

# Verifica que HACKOS_DIR/modules exista antes de intentar nada. Si el
# proyecto se movió/descargó mal, avisa exactamente dónde está buscando
# en vez de fallar en silencio módulo por módulo.
check_modules_dir() {
    if [[ ! -d "$HACKOS_DIR/modules" ]]; then
        err "No encuentro la carpeta 'modules/' junto a install.sh."
        err "HACKOS_DIR quedó en: $HACKOS_DIR"
        err "Asegurate de correr el script DESDE DENTRO de la carpeta hackOS/ (la que"
        err "tiene install.sh, modules/, lib/ y configs/ juntas), por ejemplo:"
        err "    cd hackOS && sudo bash install.sh"
        exit 1
    fi
    # Autoreparar permisos por si se perdieron al descargar/clonar (aunque
    # run_module ya no depende de +x, lo dejamos prolijo).
    chmod +x "$HACKOS_DIR/install.sh" 2>/dev/null || true
    chmod +x "$HACKOS_DIR"/modules/*.sh 2>/dev/null || true
}

# Ejecuta un módulo. Usa -f (no -x): el módulo se corre con 'bash archivo.sh'
# explícito, así que el bit de ejecución no hace falta para nada — si se
# exigiera -x, perder ese permiso al clonar/descargar el proyecto hacía que
# el instalador dijera "módulo no encontrado" con el archivo perfectamente
# presente. Ya nos pasó, por eso quedó así.
run_module() {
    local module="$1"
    local path="$HACKOS_DIR/modules/$module"
    if [[ -f "$path" ]]; then
        log "Ejecutando módulo: $module"
        bash "$path" 2>&1 | tee -a "$HACKOS_LOG_FILE"
        ok "Módulo completado: $module"
    else
        err "Módulo no encontrado: $path"
        err "Verificá que la carpeta 'modules/' esté junto a install.sh (HACKOS_DIR=$HACKOS_DIR)."
    fi
}

# --- Utilidades varias para los módulos ------------------------------------
backup_file() {
    local file="$1"
    if [[ -f "$file" && ! -f "$file.hackos-backup" ]]; then
        cp "$file" "$file.hackos-backup"
        log "Backup creado: $file.hackos-backup"
    fi
}

is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

ensure_pkg() {
    local pkg="$1"
    if ! is_installed "$pkg"; then
        log_step "Instalando $pkg..."
        apt-get install -y --no-install-recommends "$pkg"
    fi
}

# Instala el navegador elegido (o el que corresponda) en la ruta de un
# comando de terminal dentro de un archivo de config, reemplazando el
# placeholder __HACKOS_BROWSER__. Los WM (icewm/jwm/i3/cwm) usan esto para
# que el atajo de navegador siempre abra lo que elegiste en el instalador,
# no un valor fijo.
apply_browser_placeholder() {
    local target_file="$1"
    local browser_cmd="${HACKOS_BROWSER:-librewolf}"
    sed -i "s#__HACKOS_BROWSER__#${browser_cmd}#g" "$target_file"
}
