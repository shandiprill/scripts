#!/bin/bash
#
# setup-ssh-root.sh
# Configura o SSH em um container Ubuntu LXC (Proxmox) para permitir
# login do usuário root via senha.
#
# Uso:
#   chmod +x setup-ssh-root.sh
#   sudo ./setup-ssh-root.sh
#
# ATENÇÃO DE SEGURANÇA:
# Habilitar login root por senha via SSH é conveniente para um home lab,
# mas aumenta a superfície de ataque, principalmente se o container for
# exposto fora da rede local. Recomendações:
#   - Use isso apenas em rede interna/confiável (ex: VLAN do Proxmox).
#   - Prefira chaves SSH sempre que possível (veja comentário no final).
#   - Se for expor à internet, use um túnel (WireGuard/Tailscale) em vez
#     de abrir a porta 22 diretamente.

set -euo pipefail

# --- Verifica se está rodando como root ---
if [[ $EUID -ne 0 ]]; then
  echo "Este script precisa ser executado como root (use sudo)." >&2
  exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

echo "==> Atualizando pacotes e instalando openssh-server..."
apt-get update -y
apt-get install -y openssh-server

echo "==> Fazendo backup de ${SSHD_CONFIG} para ${BACKUP}..."
cp "$SSHD_CONFIG" "$BACKUP"

# --- Função para setar (ou substituir) uma diretiva no sshd_config ---
set_sshd_option() {
  local key="$1"
  local value="$2"

  if grep -qE "^\s*#?\s*${key}\b" "$SSHD_CONFIG"; then
    # Substitui a linha existente (comentada ou não)
    sed -i -E "s|^\s*#?\s*${key}\b.*|${key} ${value}|" "$SSHD_CONFIG"
  else
    # Adiciona a diretiva ao final do arquivo
    echo "${key} ${value}" >> "$SSHD_CONFIG"
  fi
}

echo "==> Ajustando diretivas no sshd_config..."
set_sshd_option "PermitRootLogin" "yes"
set_sshd_option "PasswordAuthentication" "yes"
set_sshd_option "PubkeyAuthentication" "yes"

# Alguns pacotes Ubuntu incluem overrides em /etc/ssh/sshd_config.d/
# que podem sobrescrever essas diretivas. Verifica e ajusta também.
if [ -d /etc/ssh/sshd_config.d ]; then
  for f in /etc/ssh/sshd_config.d/*.conf; do
    [ -e "$f" ] || continue
    if grep -qE "PermitRootLogin|PasswordAuthentication" "$f" 2>/dev/null; then
      echo "==> Encontrado override em $f, ajustando também..."
      cp "$f" "${f}.bak.$(date +%Y%m%d%H%M%S)"
      sed -i -E "s|^\s*#?\s*PermitRootLogin\b.*|PermitRootLogin yes|" "$f"
      sed -i -E "s|^\s*#?\s*PasswordAuthentication\b.*|PasswordAuthentication yes|" "$f"
    fi
  done
fi

# --- Define/atualiza a senha do root, se solicitado ---
# Usamos /dev/tty explicitamente porque, quando o script é executado via
# "curl ... | bash", o stdin normal está ocupado pelo conteúdo do próprio
# script (vindo da pipe), não pelo teclado. Sem isso, o "read" consumiria
# linhas do script e quebraria a execução.
echo ""
resp=""
if [ -r /dev/tty ]; then
  read -r -p "Deseja definir a senha do usuário root agora? [s/N] " resp < /dev/tty
else
  echo "Nenhum terminal interativo detectado; pulando definição de senha."
fi

case "$resp" in
  [sS]|[sS][iI][mM])
    passwd root
    ;;
  *)
    echo "Pulando definição de senha. Lembre-se de rodar 'passwd root' manualmente se necessário."
    ;;
esac

# --- Habilita e reinicia o serviço SSH ---
echo "==> Habilitando e reiniciando o serviço ssh..."
systemctl enable ssh
systemctl restart ssh

# --- Mostra status final ---
echo ""
echo "==> Status do serviço SSH:"
systemctl status ssh --no-pager -l | head -n 10

IP_ADDR=$(hostname -I | awk '{print $1}')
echo ""
echo "=================================================="
echo " Setup concluído."
echo " Teste o acesso a partir de outra máquina:"
echo "   ssh root@${IP_ADDR}"
echo ""
echo " Backup do config original salvo em:"
echo "   ${BACKUP}"
echo "=================================================="
echo ""
echo " Dica de segurança: para migrar depois para login só por chave,"
echo " copie sua chave pública com 'ssh-copy-id root@${IP_ADDR}' e então"
echo " rode este mesmo processo trocando PasswordAuthentication para 'no'."
