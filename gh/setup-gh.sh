#!/bin/bash
set -e
echo "[*] Installing GitHub CLI..."
apt-get update && apt-get install -y gh
echo "[*] GitHub CLI installed successfully!"
echo "[*] Authenticate: gh auth login"
echo "[*] Token: https://github.com/settings/tokens?type=beta"
