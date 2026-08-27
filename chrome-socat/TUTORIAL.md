# Chrome Remote Debugging + Socat - Quick Reference

## Install

### One-liner
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/chrome-socat/setup-chrome-socat.sh)"
```

### Local
```bash
bash setup-chrome-socat.sh
```

**Requisitos:**
- Root access
- Display server (X11/Xvfb)
- Google Chrome instalado
- Socat (será instalado automaticamente)

## O que Faz

- ✅ Configura serviço systemd para Chrome com Remote Debugging
- ✅ Cria relay socat (9223 → 127.0.0.1:9222)
- ✅ Expõe DevTools via porta 9223
- ✅ Inicia automaticamente no boot

## Quick Start

### 1. Executar script
```bash
sudo bash setup-chrome-socat.sh
```

### 2. Verificar status
```bash
sudo systemctl status chrome-debug.service
sudo systemctl status socat-chrome-relay.service
```

### 3. Testar conexão
```bash
# Local (via socat relay)
curl http://127.0.0.1:9223/json/version

# Remoto (IP do container)
curl http://seu-container-ip:9223/json/version
```

## Portas

- **9222** - Chrome remote debugging (localhost only)
- **9223** - Socat relay (exposto, 0.0.0.0)

## Conectar com DevTools

**Opção 1: Chrome DevTools Local**
```
chrome://inspect/#devices
Remote devices: http://127.0.0.1:9223
```

**Opção 2: Puppeteer/Playwright (automação)**
```javascript
const browser = await puppeteer.connect({
  browserWSEndpoint: 'ws://seu-container-ip:9223'
});
```

## Gerenciar Serviços

```bash
# Ver status
sudo systemctl status chrome-debug.service
sudo systemctl status socat-chrome-relay.service

# Ver logs
sudo journalctl -u chrome-debug.service -f
sudo journalctl -u socat-chrome-relay.service -f

# Reiniciar
sudo systemctl restart chrome-debug.service
sudo systemctl restart socat-chrome-relay.service

# Parar
sudo systemctl stop chrome-debug.service
sudo systemctl stop socat-chrome-relay.service
```

## Configuração

Editar em setup-chrome-socat.sh:

```bash
DISPLAY_NUM=":1"              # Display do Chrome
CHROME_DEBUG_PORT=9222        # Porta interna
SOCAT_EXTERNAL_PORT=9223      # Porta exposta
CHROME_PROFILE_DIR="/root/.chrome-debug"  # Diretório de profile
```

## Troubleshooting

**Chrome não inicia?**
```bash
sudo journalctl -u chrome-debug.service -n 50
# Verificar DISPLAY: ps aux | grep chrome
```

**Socat não conecta?**
```bash
# Testar se Chrome está escutando
curl http://127.0.0.1:9222/json/version

# Ver conexões
sudo netstat -tlnp | grep 9223
```

**"Connection refused"?**
- Verifique se ambos serviços estão rodando
- Chrome deve iniciar ANTES de socat
- Aguarde 2-3 segundos após restart

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/chrome-socat/TUTORIAL.md
