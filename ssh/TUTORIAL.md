# SSH Setup - Quick Reference

## Install

### One-liner
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/ssh/setup-ssh.sh)"
```

### Local
```bash
bash setup-ssh.sh
```

**Requisitos:**
- Root access (LXC container)
- Ubuntu/Debian

## O que Faz

- ✅ Instala OpenSSH Server
- ✅ Habilita login root via SSH
- ✅ Suporta autenticação por senha
- ✅ Suporta autenticação por chave SSH

## Quick Start

### 1. Executar script
```bash
sudo bash setup-ssh.sh
```

### 2. Definir senha de root
Quando solicitado, defina uma senha segura para root.

### 3. Testar acesso SSH
```bash
ssh root@seu-container-ip
```

## Usar Chaves SSH (Recomendado)

**Na sua máquina local:**
```bash
# Gerar chave (se não tiver)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# Copiar chave para container
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@seu-container-ip
```

**No container:**
```bash
# Desabilitar login por senha (segurança)
sudo nano /etc/ssh/sshd_config
# Alterar: PasswordAuthentication no
sudo systemctl restart ssh
```

## Gerenciar SSH

```bash
# Ver status
sudo systemctl status ssh

# Reiniciar
sudo systemctl restart ssh

# Ver logs
sudo tail -f /var/log/auth.log
```

## Configuração de Segurança

**AVISO:**
- Login root via SSH por senha aumenta risco
- Use apenas em rede interna/confiável
- Sempre prefira chaves SSH a senhas
- Se expor à internet, use VPN (WireGuard/Tailscale)

## Arquivo de Configuração

- `/etc/ssh/sshd_config` - Configuração principal
- `/etc/ssh/sshd_config.d/` - Overrides (Ubuntu 20.04+)

Backup automático criado: `/etc/ssh/sshd_config.bak.*`

## Troubleshooting

**Conexão recusada?**
```bash
sudo systemctl status ssh
sudo journalctl -u ssh -n 20
```

**Senha não funciona?**
- Verifique se PasswordAuthentication está `yes` em sshd_config
- Reinicie SSH: `sudo systemctl restart ssh`

**Chave SSH não funciona?**
- Verifique permissões: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`
- Teste: `ssh -vv root@seu-container-ip`

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/ssh/TUTORIAL.md
