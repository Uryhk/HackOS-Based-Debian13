#!/usr/bin/env bash
# hackOS :: 12-nomad — Project N.O.M.A.D (Crosstalk-Solutions)
# https://github.com/Crosstalk-Solutions/project-nomad
#
# "Computadora de supervivencia offline": panel web (Command Center) que
# administra contenedores Docker con herramientas/conocimiento offline
# (Kiwix, mapas, asistente IA local, etc). Corre en http://localhost:8080
#
# NOTA DE RECURSOS: esto instala Docker y deja el Command Center corriendo
# como servicio. El daemon de Docker + el contenedor base del Command Center
# suman RAM/disco en reposo (además de lo que instales después vía "Supply
# Depot", que puede ser bastante pesado — mapas offline completos son 120GB+).
# Si tu prioridad es el consumo mínimo de ~700MB, instalá este módulo aparte
# y solo cuando lo vayas a usar; no es parte del set "base" recomendado.
set -euo pipefail

apt-get install -y --no-install-recommends curl ca-certificates

log() { echo "[hackOS] $*"; }

# --- Docker (requisito de NOMAD; el instalador oficial también lo hace,
#     pero lo dejamos explícito para que quede vía apt y no vía curl|sh) ---
if ! command -v docker >/dev/null 2>&1; then
    log "Instalando Docker Engine..."
    install -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    ARCH="$(dpkg --print-architecture)"
    CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${CODENAME} stable" \
        > /etc/apt/sources.list.d/docker.list
    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
fi

# --- Instalador oficial de Project NOMAD --------------------------------
NOMAD_INSTALLER="/tmp/install_nomad.sh"
curl -fsSL https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/main/install/install_nomad.sh \
    -o "$NOMAD_INSTALLER"
bash "$NOMAD_INSTALLER"

# --- Acceso local: UFW no bloquea loopback, así que localhost:8080 ya
#     funciona. Si además querés acceder desde otros equipos de tu LAN: ---
cat > /usr/local/bin/hackos-nomad-lan-access <<'EOF'
#!/usr/bin/env bash
# Habilita acceso al Command Center de NOMAD (puerto 8080) desde tu LAN.
set -euo pipefail
ufw allow from 192.168.0.0/16 to any port 8080 proto tcp comment "Project NOMAD LAN"
ufw allow from 10.0.0.0/8 to any port 8080 proto tcp comment "Project NOMAD LAN"
echo "[hackOS] Acceso LAN a NOMAD habilitado en :8080."
EOF
chmod 755 /usr/local/bin/hackos-nomad-lan-access

log "Project N.O.M.A.D instalado. Abrí http://localhost:8080 para configurarlo."
log "Acceso desde otros equipos de tu red: sudo hackos-nomad-lan-access"
