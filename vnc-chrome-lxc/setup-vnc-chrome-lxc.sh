#!/bin/bash
#
# setup-vnc-chrome-lxc.sh
#
# Instala e configura ambiente gráfico (XFCE) + servidor VNC (TigerVNC) +
# Google Chrome dentro de um LXC Ubuntu no Proxmox, com acesso remoto via
# VNC (ex: cliente VNC no iPhone, Mac, etc).
#
# COMO USAR:
#   1. Crie o LXC Ubuntu (privilegiado) via community-scripts no host Proxmox:
#      bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/ubuntu.sh)"
#   2. Entre no container (pct enter <ID>) e rode este script como root:
#      bash setup-vnc-chrome-lxc.sh
#   3. Ao final, defina a senha do VNC quando solicitado (comando vncpasswd).
#
# Requisitos recomendados do LXC: privilegiado, 2 vCPU, 3-4GB RAM, 20GB disco.

set -e

echo "==> Atualizando pacotes do sistema..."
apt update && apt upgrade -y

echo "==> Instalando ambiente gráfico leve (XFCE)..."
apt install -y xfce4 xfce4-goodies dbus-x11

echo "==> Instalando servidor VNC (TigerVNC)..."
apt install -y tigervnc-standalone-server tigervnc-common

echo "==> Instalando dependências e Google Chrome..."
apt install -y wget gnupg ca-certificates socat
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt update
apt install -y google-chrome-stable

echo "==> Configurando arquivo de inicialização da sessão VNC (xstartup)..."
mkdir -p ~/.vnc
touch ~/.Xresources

cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
exec dbus-launch --exit-with-session startxfce4
EOF

chmod +x ~/.vnc/xstartup

echo "==> Criando serviço systemd para o VNC (display :1 / porta 5901)..."
cat > /etc/systemd/system/vncserver@.service << 'EOF'
[Unit]
Description=Remote desktop VNC service
After=syslog.target network.target

[Service]
Type=forking
User=root
WorkingDirectory=/root
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost no :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

echo "==> Recarregando systemd..."
systemctl daemon-reload

echo ""
echo "=================================================================="
echo "  Agora defina a senha de acesso ao VNC (mínimo 6 caracteres):"
echo "=================================================================="
vncpasswd

echo "==> Ativando e iniciando o serviço VNC..."
systemctl enable --now vncserver@1

echo ""
echo "=================================================================="
echo "  Instalação concluída!"
echo "=================================================================="
echo "  IP do container: $(hostname -I | awk '{print $1}')"
echo "  Porta VNC: 5901 (display :1)"
echo ""
echo "  Conecte usando um cliente VNC (ex: RealVNC Viewer no iPhone/Mac)"
echo "  apontando para: $(hostname -I | awk '{print $1}'):5901"
echo "=================================================================="

systemctl status vncserver@1 --no-pager
