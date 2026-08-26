# Claude Code - Instalação em Proxmox LXC

Instale **Claude Code** em um container Ubuntu LXC no Proxmox para desenvolvimento remoto acessível do seu celular, com integração GitHub e suporte a projetos leves.

---

## 📋 Pré-requisitos

- **Proxmox VE** instalado
- Acesso ao **shell do Proxmox** (PVE)
- **Celular/Tablet** com navegador web ou app Claude

---

## 🚀 Quick Start - Uma Linha

### 1️⃣ Criar Container no Proxmox

No **shell do Proxmox**, execute:

```bash
var_cpu="2" var_ram="3072" var_disk="12" bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/ubuntu.sh)"
```

**O que isso faz:**
- CPU: 2 cores
- RAM: 3 GB
- Disco: 12 GB
- Sistema: Ubuntu 24 LTS

**Anotações importantes:**
- Anote o **CTID** (Container ID) que aparecerá na tela
- Anote o **IP do container** que será exibido

---

### 2️⃣ Entrar no Shell do Container

Após criar, ainda no **shell do Proxmox**:

```bash
pct shell CTID
```

Substitua `CTID` pelo ID do seu container (ex: `pct shell 100`)

---

### 3️⃣ Executar Script de Instalação

Agora **dentro do container**, execute:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/install-claude-code.sh)"
```

**Isso instala:**
- ✅ Node.js 20.x
- ✅ Claude Code CLI
- ✅ Usuário dedicado `claude`
- ✅ Serviço systemd (auto-start)
- ✅ GitHub MCP Server

---

## 🔧 Configuração Pós-Instalação

### Adicionar Token GitHub

O script criou o arquivo de config em:
```
/home/claude/.claude/claude_desktop_config.json
```

**Para editar:**

```bash
sudo nano /home/claude/.claude/claude_desktop_config.json
```

**Substitua:**
```json
"GITHUB_PERSONAL_ACCESS_TOKEN": "seu_token_aqui"
```

**Gerar um token:**
1. Acesse: https://github.com/settings/tokens?type=beta
2. Clique em "Generate new token"
3. Dê um nome (ex: "claude-code-proxmox")
4. Selecione permissões: `repo`, `workflow`
5. Copie o token e cole no arquivo

**Salvar (Ctrl+O, Enter, Ctrl+X)**

---

## 📱 Acessar do Celular

### Opção 1: Mesma Rede (Local)

1. Descubra o IP do container:
```bash
# Dentro do container
ip addr show
```

2. No navegador do celular (mesma rede WiFi):
```
http://SEU_IP_CONTAINER:8000
```

**Exemplo:** `http://192.168.1.150:8000`

---

### Opção 2: Remoto via WireGuard (MikroTik Router)

Como seu Proxmox está atrás de WireGuard no MikroTik:

1. Certifique-se que o container tem IP na rede local do Proxmox
2. Acesse via WireGuard: `http://SEU_IP_CONTAINER:8000`

**Exemplo:**
- Proxmox IP: `192.168.1.100`
- Container IP: `192.168.1.150`
- Acesse de fora: `http://192.168.1.150:8000` (via WireGuard)

---

## 🔗 Conectar Projetos GitHub

### Clonar um repositório:

```bash
cd /home/claude/projects
git clone https://github.com/SEU_USUARIO/SEU_REPO.git
cd SEU_REPO
```

Claude Code terá acesso aos arquivos e poderá fazer commits via MCP.

---

## 📊 Monitorar & Manutenção

### Ver status do serviço:
```bash
sudo systemctl status claude-code.service
```

### Ver logs em tempo real:
```bash
sudo journalctl -u claude-code.service -f
```

### Reiniciar serviço:
```bash
sudo systemctl restart claude-code.service
```

### Parar serviço:
```bash
sudo systemctl stop claude-code.service
```

### Iniciar novamente:
```bash
sudo systemctl start claude-code.service
```

---

## 📁 Estrutura de Arquivos

```
/home/claude/
├── projects/                           # Seus projetos aqui
│   ├── meu-site-estatico/
│   ├── fluxo-n8n/
│   └── README.md
├── .claude/
│   └── claude_desktop_config.json      # Configuração MCP (EDITAR!)
└── .local/                             # Cache do npm
```

---

## 💡 Casos de Uso

### ✅ Sites Estáticos HTML/CSS/JS
```bash
cd /home/claude/projects
mkdir meu-site
# Claude Code ajudará com HTML, CSS, responsividade
```

### ✅ Organizar Fluxo n8n
```bash
# Edite JSONs de workflows do n8n
nano workflow.json
# Claude Code entende estrutura n8n e pode ajudar a otimizar
```

### ✅ Scripts Python/Node
```bash
# Criar e editar scripts
echo "console.log('Hello');" > script.js
# Claude Code executa e depura
```

---

## 🔒 Segurança

Como seu acesso é via **WireGuard no MikroTik**, a rede já é segura. Boas práticas adicionais:

1. Mantenha o **WireGuard** ativo no router
2. Use **SSH keys** em vez de senhas no container
3. Guarde **tokens GitHub** com segurança em `/home/claude/.claude/claude_desktop_config.json`
4. Não compartilhe URLs do Claude Code publicamente

---

## 🛠️ Troubleshooting

### "Claude Code não conecta"
```bash
# Verificar se serviço está rodando
sudo systemctl status claude-code.service

# Reiniciar
sudo systemctl restart claude-code.service

# Ver erros
sudo journalctl -u claude-code.service -n 50
```

### "GitHub MCP não funciona"
1. Verifique se o token está configurado corretamente
2. Teste gerando um novo token
3. Confirme se as permissões `repo` estão habilitadas

### "Celular não conecta ao container"
1. Confirme que está conectado ao WireGuard do MikroTik
2. Ping do celular para o container: `ping SEU_IP_CONTAINER`
3. Verifique firewall do MikroTik (porta 8000 liberada)
4. Teste com SSH primeiro: `ssh -l usuario SEU_IP_CONTAINER`

### "Porta 8000 não responde"
```bash
# Verificar se está escutando
sudo netstat -tlnp | grep 8000

# Se não aparecer, reinicie
sudo systemctl restart claude-code.service
```

---

## 📚 Referências

- [Claude Code Docs](https://anthropic.com/claude-code)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Proxmox_VE_Administration_Guide)
- [Tailscale Setup](https://tailscale.com/download)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)

