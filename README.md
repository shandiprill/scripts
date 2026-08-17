# scripts

Setup scripts for my Proxmox home lab (Ubuntu LXC containers).

## Requirements

- Ubuntu LXC container (Proxmox)
- Run as root or with `sudo`
- Internet access from the container

---

## 1. setup-ssh.sh

[setup-ssh.sh](https://github.com/shandiprill/scripts/blob/main/setup-ssh.sh)

Installs and configures OpenSSH server, enabling root login with password authentication.

```bash
curl -fsSL -o setup-ssh.sh https://raw.githubusercontent.com/shandiprill/scripts/refs/heads/main/setup-ssh.sh
chmod +x setup-ssh.sh
sudo ./setup-ssh.sh
```

---

## 2. setup-vnc-chrome-lxc.sh

[setup-vnc-chrome-lxc.sh](https://github.com/shandiprill/scripts/blob/main/setup-vnc-chrome-lxc.sh)

Sets up a desktop environment (XFCE4) with TigerVNC and Chrome inside the LXC container, for remote GUI access.

```bash
curl -fsSL -o setup-vnc-chrome-lxc.sh https://raw.githubusercontent.com/shandiprill/scripts/refs/heads/main/setup-vnc-chrome-lxc.sh
chmod +x setup-vnc-chrome-lxc.sh
sudo ./setup-vnc-chrome-lxc.sh
```

---

## 3. setup-chrome-socat.sh

[setup-chrome-socat.sh](https://github.com/shandiprill/scripts/blob/main/setup-chrome-socat.sh)

Configures Chrome remote debugging (CDP) and relays the debug port externally using socat, for use with browser automation tools (e.g. n8n, Puppeteer).

```bash
curl -fsSL -o setup-chrome-socat.sh https://raw.githubusercontent.com/shandiprill/scripts/refs/heads/main/setup-chrome-socat.sh
chmod +x setup-chrome-socat.sh
sudo ./setup-chrome-socat.sh
```

---

## Notes

- All scripts create a backup of any config files they modify before making changes.
- Review each script before running it, especially if the container will be exposed outside your local network.
