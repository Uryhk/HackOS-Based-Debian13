#!/usr/bin/env bash
# hackOS :: 10-audit — herramientas de auditoría de seguridad
set -euo pipefail
HACKOS_DIR="${HACKOS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export HACKOS_DIR
source "$HACKOS_DIR/lib/common.sh"

apt-get install -y --no-install-recommends \
    lynis rkhunter chkrootkit aide debsums

# --- Baseline de AIDE (integridad de archivos) ---------------------------
aideinit -y -f 2>/dev/null || (aide --init && mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db) || true

# --- rkhunter: actualizar base de datos de propiedades ------------------
rkhunter --propupd || true
rkhunter --update || true

# --- Auditoría semanal automática -----------------------------------------
install -d /etc/hackos
cat > /usr/local/bin/hackos-audit <<'EOF'
#!/usr/bin/env bash
# Auditoría de seguridad hackOS: corre lynis + rkhunter + chkrootkit
# y deja el reporte en /var/log/hackos-audit/
set -euo pipefail
OUT="/var/log/hackos-audit"
install -d "$OUT"
STAMP=$(date +%Y%m%d-%H%M%S)

echo "== Lynis =="   | tee "$OUT/audit-$STAMP.log"
lynis audit system --quick 2>&1 | tee -a "$OUT/audit-$STAMP.log"
echo "== rkhunter ==" | tee -a "$OUT/audit-$STAMP.log"
rkhunter --check --skip-keypress 2>&1 | tee -a "$OUT/audit-$STAMP.log"
echo "== chkrootkit ==" | tee -a "$OUT/audit-$STAMP.log"
chkrootkit 2>&1 | tee -a "$OUT/audit-$STAMP.log"

echo "Reporte guardado en $OUT/audit-$STAMP.log"
EOF
chmod 755 /usr/local/bin/hackos-audit

cat > /etc/systemd/system/hackos-audit.service <<'EOF'
[Unit]
Description=hackOS security audit (lynis + rkhunter + chkrootkit)

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hackos-audit
EOF

cat > /etc/systemd/system/hackos-audit.timer <<'EOF'
[Unit]
Description=Corre la auditoría de seguridad hackOS semanalmente

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable hackos-audit.timer

echo "[hackOS] Herramientas de auditoría instaladas. Auditoría semanal automática activada."
echo "[hackOS] Auditoría manual: sudo hackos-audit"
