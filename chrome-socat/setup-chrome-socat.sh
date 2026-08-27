#!/bin/bash
set -e

# ---- Config (ajuste se precisar) ----
DISPLAY_NUM=":1"
CHROME_DEBUG_PORT=9222
SOCAT_EXTERNAL_PORT=9223
CHROME_PROFILE_DIR="/root/.chrome-debug"

echo ">> Criando ${CHROME_PROFILE_DIR} se não existir..."
mkdir -p "$CHROME_PROFILE_DIR"

# ---- Serviço do Chrome ----
echo ">> Escrevendo /etc/systemd/system/chrome-debug.service"
cat > /etc/systemd/system/chrome-debug.service <<EOF
[Unit]
Description=Chrome com Remote Debugging (display ${DISPLAY_NUM})
After=network.target

[Service]
Type=simple
Environment="DISPLAY=${DISPLAY_NUM}"
ExecStart=/usr/bin/google-chrome \\
  --remote-debugging-port=${CHROME_DEBUG_PORT} \\
  --no-sandbox \\
  --disable-dev-shm-usage \\
  --disable-gpu \\
  --user-data-dir=${CHROME_PROFILE_DIR} \\
  --disable-background-networking \\
  --disable-background-timer-throttling \\
  --disable-client-side-phishing-detection \\
  --disable-popup-blocking \\
  --disable-prompt-on-repost \\
  --disable-sync \\
  --metrics-recording-only \\
  --no-first-run \\
  about:blank
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

# ---- Serviço do socat (relay 9223 -> 127.0.0.1:9222) ----
echo ">> Escrevendo /etc/systemd/system/socat-chrome-relay.service"
cat > /etc/systemd/system/socat-chrome-relay.service <<EOF
[Unit]
Description=Socat relay para expor o Chrome DevTools (porta ${SOCAT_EXTERNAL_PORT} -> 127.0.0.1:${CHROME_DEBUG_PORT})
After=network.target chrome-debug.service
Requires=chrome-debug.service

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP4-LISTEN:${SOCAT_EXTERNAL_PORT},fork,reuseaddr TCP4:127.0.0.1:${CHROME_DEBUG_PORT}
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

# ---- Verifica se socat está instalado ----
if ! command -v socat &> /dev/null; then
    echo ">> socat não encontrado, instalando..."
    apt-get update && apt-get install -y socat
fi

# ---- Ativa os serviços ----
echo ">> Recarregando systemd e ativando serviços..."
systemctl daemon-reload
systemctl enable chrome-debug.service
systemctl enable socat-chrome-relay.service
systemctl restart chrome-debug.service
sleep 3
systemctl restart socat-chrome-relay.service

echo ""
echo "=== Status ==="
systemctl status chrome-debug.service --no-pager -l | head -n 10
echo ""
systemctl status socat-chrome-relay.service --no-pager -l | head -n 10

echo ""
echo ">> Pronto. Teste com:"
echo "   curl http://127.0.0.1:${CHROME_DEBUG_PORT}/json/version"
echo "   curl http://$(hostname -I | awk '{print $1}'):${SOCAT_EXTERNAL_PORT}/json/version"
