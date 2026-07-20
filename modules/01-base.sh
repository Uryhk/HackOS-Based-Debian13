#!/usr/bin/env bash
# hackOS :: 01-base — sistema base, kernel endurecido, hardening general
set -euo pipefail

apt-get update -qq
apt-get install -y --no-install-recommends \
    build-essential git curl wget ca-certificates gnupg2 \
    apt-transport-https software-properties-common \
    xorg xinit x11-xserver-utils xserver-xorg-video-all \
    network-manager network-manager-gnome \
    firmware-linux firmware-misc-nonfree \
    apparmor apparmor-profiles apparmor-utils apparmor-profiles-extra \
    ufw fail2ban unattended-upgrades \
    macchanger \
    zram-tools \
    policykit-1 \
    sudo

# --- Kernel endurecido -------------------------------------------------
# Debian 13 trae el kernel "linux-image-*-hardened" en algunos repos de
# terceros; usamos linux-hardened vía backport de Debian testing/security
# si está disponible, y si no, aplicamos hardening por sysctl + linux-image-amd64.
if apt-cache search '^linux-image-.*-hardened$' 2>/dev/null | grep -q hardened; then
    apt-get install -y linux-image-amd64-hardened || apt-get install -y linux-image-amd64
else
    apt-get install -y linux-image-amd64 linux-headers-amd64
fi

# --- sysctl hardening (inspirado en Kicksecure) -------------------------
install -d /etc/sysctl.d
cat > /etc/sysctl.d/99-hackos-hardening.conf <<'EOF'
# hackOS hardening — inspirado en Kicksecure/CIS

# Kernel
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.printk = 3 3 3 3
kernel.unprivileged_bpf_disabled = 1
kernel.yama.ptrace_scope = 2
kernel.kexec_load_disabled = 1
kernel.sysrq = 0
kernel.core_pattern = |/bin/false
kernel.perf_event_paranoid = 3

# Red
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0

# Filesystem
fs.protected_fifos = 2
fs.protected_regular = 2
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0

# ASLR completo
kernel.randomize_va_space = 2
EOF
sysctl --system || true

# --- Firewall por defecto ------------------------------------------------
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# --- AppArmor en modo enforce --------------------------------------------
systemctl enable apparmor || true
aa-enforce /etc/apparmor.d/* 2>/dev/null || true

# --- Reducir superficie: deshabilitar módulos de kernel poco usados -----
cat > /etc/modprobe.d/hackos-blacklist.conf <<'EOF'
# hackOS — protocolos raramente usados y con historial de vulnerabilidades
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
blacklist cramfs
blacklist freevxfs
blacklist jffs2
blacklist hfs
blacklist hfsplus
blacklist udf
blacklist firewire-core
EOF

# --- zram para bajo consumo de RAM en máquinas de pocos recursos ---------
cat > /etc/default/zramswap <<'EOF'
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF
systemctl enable zramswap || true

# --- Usuario hackOS por defecto (si no existe uno interactivo) ----------
if ! id -u hackos >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo,netdev hackos || true
    echo "hackos:hackos" | chpasswd || true
    echo "[hackOS] Usuario 'hackos' creado con contraseña temporal 'hackos'. CAMBIALA al primer login."
fi

echo "[hackOS] Base + hardening instalados."

# --- GRUB: habilitar boot splash (Plymouth) -------------------------------
if [[ -f /etc/default/grub ]] && command -v update-grub >/dev/null 2>&1; then
    if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' >> /etc/default/grub
    fi
    update-grub || true
fi
