# Claude Code Setup - Quick Reference

## Install
```bash
bash setup-claude.sh
```

**Requisitos:**
- Root access (LXC container)
- Ubuntu/Debian 20.04+
- Conexão à internet

## O que é Instalado

- ✅ Node.js 20.x
- ✅ Claude Code CLI
- ✅ Usuário dedicado `claude`
- ✅ Serviço systemd para auto-start
- ✅ GitHub MCP Server

## Quick Start

### 1. Executar script
```bash
sudo bash setup-claude.sh
```

### 2. Configurar Token GitHub
```bash
sudo nano /home/claude/.claude/claude_desktop_config.json
```

Substitua:
```json
"GITHUB_PERSONAL_ACCESS_TOKEN": "seu_token_aqui"
```

Gere token em: https://github.com/settings/tokens?type=beta

### 3. Acessar Claude Code
Via navegador (mesma rede):
```
http://seu-container-ip:8000
```

## Gerenciar Serviço

```bash
# Ver status
sudo systemctl status claude-code.service

# Ver logs em tempo real
sudo journalctl -u claude-code.service -f

# Reiniciar
sudo systemctl restart claude-code.service

# Parar
sudo systemctl stop claude-code.service

# Iniciar
sudo systemctl start claude-code.service
```

## Diretórios Importantes

- `/home/claude/projects/` - Seus projetos
- `/home/claude/.claude/claude_desktop_config.json` - Configuração MCP

## Troubleshooting

**Claude Code não conecta?**
```bash
systemctl status claude-code.service
sudo journalctl -u claude-code.service -n 50
```

**Serviço recusa iniciar?**
- Verifique se porta 8000 está disponível
- Confira Node.js: `node --version`

**GitHub MCP não funciona?**
1. Verifique token em `claude_desktop_config.json`
2. Token precisa ter permissões: `repo`, `workflow`
3. Reinicie: `systemctl restart claude-code.service`

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/claude/TUTORIAL.md
