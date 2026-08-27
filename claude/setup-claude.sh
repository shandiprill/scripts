#!/bin/bash

###############################################################################
# Claude Code Installation & Setup Script
# Instala Claude Code em um container Ubuntu/Debian com:
# - Node.js
# - Claude Code CLI
# - Configuração de usuário dedicado
# - Serviço systemd para auto-start
# - Integração com GitHub via MCP
###############################################################################

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens coloridas
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

###############################################################################
# Verificar se é root
###############################################################################
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root!"
   exit 1
fi

###############################################################################
# 1. ATUALIZAR SISTEMA
###############################################################################
print_header "Atualizando Sistema"

apt update
apt upgrade -y
apt install -y curl wget git build-essential

print_success "Sistema atualizado"

###############################################################################
# 2. INSTALAR NODE.JS
###############################################################################
print_header "Instalando Node.js 20.x"

if command -v node &> /dev/null; then
    print_warning "Node.js já está instalado: $(node --version)"
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
    print_success "Node.js instalado: $(node --version)"
    print_success "npm instalado: $(npm --version)"
fi

###############################################################################
# 3. CRIAR USUÁRIO DEDICADO
###############################################################################
print_header "Configurando Usuário Dedicado"

if id -u "claude" &>/dev/null 2>&1; then
    print_warning "Usuário 'claude' já existe"
else
    useradd -m -s /bin/bash -G sudo claude
    print_success "Usuário 'claude' criado"
fi

# Criar diretório de projetos
mkdir -p /home/claude/projects
mkdir -p /home/claude/.claude
chown -R claude:claude /home/claude

print_success "Diretórios criados: /home/claude/projects"

###############################################################################
# 4. INSTALAR CLAUDE CODE
###############################################################################
print_header "Instalando Claude Code"

# Instalar globalmente
npm install -g @anthropic-ai/claude-code

print_success "Claude Code instalado"

# Verificar instalação
if command -v claude-code &> /dev/null; then
    print_success "Claude Code disponível: $(claude-code --version 2>/dev/null || echo 'versão não disponível')"
else
    print_warning "Claude Code não encontrado no PATH. Tentando npm prefix..."
    CLAUDE_PATH=$(npm config get prefix)/bin/claude-code
    print_success "Claude Code instalado em: $CLAUDE_PATH"
fi

###############################################################################
# 5. CONFIGURAR SERVIÇO SYSTEMD
###############################################################################
print_header "Criando Serviço Systemd"

cat > /etc/systemd/system/claude-code.service << 'EOF'
[Unit]
Description=Claude Code Server
After=network.target
Documentation=https://github.com/anthropics/claude-code

[Service]
Type=simple
User=claude
Group=claude
WorkingDirectory=/home/claude/projects
ExecStart=/usr/local/bin/claude-code --listen 0.0.0.0:8000
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SyslogIdentifier=claude-code

[Install]
WantedBy=multi-user.target
EOF

# Criar symlink para o executável (se necessário)
CLAUDE_BIN=$(npm config get prefix)/bin/claude-code
if [ -f "$CLAUDE_BIN" ]; then
    ln -sf "$CLAUDE_BIN" /usr/local/bin/claude-code 2>/dev/null || true
fi

# Recarregar daemon
systemctl daemon-reload
systemctl enable claude-code.service

print_success "Serviço systemd 'claude-code' criado e habilitado"

###############################################################################
# 6. CONFIGURAR GITHUB MCP
###############################################################################
print_header "Configurando GitHub MCP Server"

# Criar arquivo de configuração
cat > /home/claude/.claude/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "seu_token_aqui"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "/home/claude/projects"],
      "disabled": false
    }
  }
}
EOF

chown claude:claude /home/claude/.claude/claude_desktop_config.json
chmod 600 /home/claude/.claude/claude_desktop_config.json

print_success "Configuração MCP criada"
print_warning "Edite o token GitHub em: /home/claude/.claude/claude_desktop_config.json"
print_warning "Gere o token em: https://github.com/settings/tokens"

###############################################################################
# 7. CRIAR PASTA DE EXEMPLO
###############################################################################
print_header "Criando Estrutura de Projetos"

sudo -u claude bash << 'EOF'
cd /home/claude/projects

# Criar arquivo de exemplo
cat > README.md << 'EOFREADME'
# Meus Projetos

Bem-vindo ao seu ambiente Claude Code!

## Estrutura
- Clones de repositórios: clone direto aqui
- Projetos estáticos: crie sites, scripts, etc
- Configurações n8n: edite flows JSON

## Quick Start

```bash
git clone seu-repo-aqui
cd seu-repo
# Claude Code ajudará com o desenvolvimento
```

## Acessar Claude Code

- **Via WireGuard (Proxmox):** http://seu-container-ip:8000

EOFREADME

print "✓ Projetos estruturados"
EOF

print_success "Estrutura de projetos criada"

###############################################################################
# 8. INICIAR SERVIÇO
###############################################################################
print_header "Iniciando Serviço Claude Code"

systemctl start claude-code.service

# Aguardar um pouco para o serviço iniciar
sleep 3

# Verificar status
if systemctl is-active --quiet claude-code.service; then
    print_success "Serviço Claude Code iniciado com sucesso!"
else
    print_error "Erro ao iniciar serviço. Verifique logs:"
    print_error "sudo journalctl -u claude-code.service -n 50"
fi

###############################################################################
# 11. EXIBIR INFORMAÇÕES FINAIS
###############################################################################
print_header "Instalação Concluída!"

echo -e "${GREEN}=== INFORMAÇÕES DE ACESSO ===${NC}\n"

# Obter IPs
CONTAINER_IP=$(hostname -I | awk '{print $1}')

echo "Local (mesma rede):"
echo "  http://${CONTAINER_IP}:8000"
echo ""

echo "Serviço Status:"
systemctl status claude-code.service --no-pager
echo ""

echo -e "${BLUE}=== PRÓXIMAS PASSOS ===${NC}\n"

echo "1. Configurar GitHub Token:"
echo "   sudo nano /home/claude/.claude/claude_desktop_config.json"
echo "   (Gere em: https://github.com/settings/tokens?type=beta)"
echo ""

echo "2. Ver logs do serviço:"
echo "   sudo journalctl -u claude-code.service -f"
echo ""

echo "3. Reiniciar serviço:"
echo "   sudo systemctl restart claude-code.service"
echo ""

echo "4. Parar serviço:"
echo "   sudo systemctl stop claude-code.service"
echo ""

echo "5. Iniciar serviço:"
echo "   sudo systemctl start claude-code.service"
echo ""

echo -e "${GREEN}✓ Tudo pronto! Acesse Claude Code via WireGuard em: http://${CONTAINER_IP}:8000${NC}\n"
