#!/usr/bin/env bash
# hackOS :: 09-privacy-tor — capa de privacidad estilo Whonix/Kicksecure
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

apt-get install -y --no-install-recommends \
    tor torbrowser-launcher torsocks obfs4proxy \
    macchanger dnscrypt-proxy iptables

systemctl enable tor
systemctl enable dnscrypt-proxy || true

# --- Randomización de MAC en cada conexión (como Whonix hace por defecto) -
cat > /etc/NetworkManager/conf.d/99-hackos-mac-random.conf <<'EOF'
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
connection.stable-id=${CONNECTION}/${BOOT}
EOF
systemctl restart NetworkManager || true

# --- DNS cifrado por defecto (evita fugas DNS) ---------------------------
install -d /etc/dnscrypt-proxy
cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml <<'EOF'
server_names = ['cloudflare', 'mullvad-doh']
listen_addresses = ['127.0.0.1:53']
require_dnssec = true
require_nolog = true
require_nofilter = false
ipv6_servers = false
block_ipv6 = true
EOF

cat > /etc/systemd/resolved.conf.d/hackos-dnscrypt.conf <<'EOF'
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
install -d /etc/systemd/resolved.conf.d

# --- Deshabilitar servicios de "phone home" / telemetría ------------------
systemctl disable apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true
systemctl mask motd-news.timer 2>/dev/null || true

# --- Torificación opcional a nivel sistema (modo "workstation" estilo
#     Whonix, NO redirige todo el tráfico salvo que el usuario lo pida) ---
install -d /usr/local/bin
cat > /usr/local/bin/hackos-torify-toggle <<'EOF'
#!/usr/bin/env bash
# Activa/desactiva el enrutamiento transparente de tráfico TCP por Tor.
# ADVERTENCIA: esto NO es tan robusto como una Whonix-Gateway real de dos VMs;
# es una torificación a nivel de sistema único, útil pero no anonimato total.
set -euo pipefail
ACTION="${1:-status}"
RULES_FILE="/etc/hackos/torify.rules.v4"

case "$ACTION" in
  on)
    iptables-restore < "$RULES_FILE"
    echo "[hackOS] Tráfico TCP torificado a nivel sistema (modo Whonix-like)."
    ;;
  off)
    iptables -F
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    echo "[hackOS] Torificación desactivada, reglas de firewall reseteadas."
    ;;
  status)
    iptables -L -n -v | head -20
    ;;
  *)
    echo "Uso: hackos-torify-toggle {on|off|status}"; exit 1 ;;
esac
EOF
chmod 755 /usr/local/bin/hackos-torify-toggle

install -d /etc/hackos
cat > /etc/hackos/torify.rules.v4 <<'EOF'
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A OUTPUT -m owner --uid-owner debian-tor -j RETURN
-A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353
-A OUTPUT -p tcp -m tcp --syn -j REDIRECT --to-ports 9040
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
-A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p tcp -m tcp --dport 9040 -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
COMMIT
EOF

echo "[hackOS] Capa de privacidad instalada: Tor, DNS cifrado, MAC random, torify-toggle."
echo "[hackOS] Activar torificación total: sudo hackos-torify-toggle on"
