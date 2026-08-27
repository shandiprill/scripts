# VNC + Chrome + XFCE (LXC) - Quick Reference

## Install

### One-liner
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/vnc-chrome-lxc/setup-vnc-chrome-lxc.sh)"
```

### Local
```bash
bash setup-vnc-chrome-lxc.sh
```

**Requisitos:**
- LXC Ubuntu 20.04+ (privilegiado recomendado)
- 2 vCPU, 3-4GB RAM, 20GB disco (recomendado)
- Root access

## O que Faz

- ✅ Instala ambiente gráfico XFCE
- ✅ Configura servidor VNC (TigerVNC)
- ✅ Instala Google Chrome
- ✅ Cria serviço systemd para auto-start

## Quick Start

### 1. Executar script
```bash
sudo bash setup-vnc-chrome-lxc.sh
```

### 2. Definir senha VNC
Quando solicitado, defina uma senha (mínimo 6 caracteres).

### 3. Conectar via VNC
**IP do container:** (mostrado ao final do script)
**Porta:** 5901 (display :1)

```
vnc://seu-container-ip:5901
```

**Clientes VNC:**
- RealVNC Viewer (iPhone, Mac, Windows)
- TightVNC (Windows, Linux)
- Remmina (Linux)
- Jump Desktop (iPad)

## Gerenciar VNC

```bash
# Ver status
sudo systemctl status vncserver@1

# Ver logs
sudo journalctl -u vncserver@1 -f

# Reiniciar
sudo systemctl restart vncserver@1

# Parar
sudo systemctl stop vncserver@1

# Iniciar
sudo systemctl start vncserver@1
```

## Configuração VNC

**Arquivo de inicialização:** `~/.vnc/xstartup`
**Serviço systemd:** `/etc/systemd/system/vncserver@.service`

Alterar resolução em vncserver@.service:
```
ExecStart=/usr/bin/vncserver -geometry 1920x1080 :%i
```

Depois reiniciar:
```bash
sudo systemctl restart vncserver@1
```

## Executar Chrome

Dentro da sessão VNC:
1. Abra o terminal (Ctrl+Alt+T)
2. Digite: `google-chrome`
3. Ou use Menu → Applications → Chrome

## Troubleshooting

**Não consigo conectar?**
```bash
sudo systemctl status vncserver@1
sudo journalctl -u vncserver@1 -n 50
```

**Esqueci a senha VNC?**
```bash
vncpasswd
sudo systemctl restart vncserver@1
```

**Tela preta / congelada?**
```bash
# Reiniciar VNC
sudo systemctl restart vncserver@1

# Ou matar processo
sudo vncserver -kill :1
sudo systemctl start vncserver@1
```

**Chrome não inicia?**
- Verifique RAM e CPU disponíveis
- Teste em terminal: `google-chrome --new-window`

**Performance lenta?**
- Reduzir cores de 24 para 16 bits em vncserver@.service
- Usar menor resolução
- Verificar latência de rede (WireGuard/LAN)

## Portas

- **5901** - VNC Server (display :1)

## Arquivos Importantes

- `~/.vnc/xstartup` - Script de inicialização da sessão
- `/etc/systemd/system/vncserver@.service` - Configuração do serviço
- `~/.vnc/passwd` - Senha criptografada

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/vnc-chrome-lxc/TUTORIAL.md
