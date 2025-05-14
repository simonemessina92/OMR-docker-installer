#!/bin/sh

echo "[INFO] Updating package list..."
opkg update

echo "[INFO] Installing Docker and LuCI web interface..."
opkg install docker dockerd docker-compose luci-app-dockerman

echo "[INFO] Enabling and starting Docker service..."
/etc/init.d/dockerd enable
/etc/init.d/dockerd start

echo "[✅] Docker installation complete."
echo "Access the Docker interface in LuCI: Services > Docker"
