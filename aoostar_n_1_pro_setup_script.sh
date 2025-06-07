#!/bin/bash

set -e

echo "[1/8] 🧼 Aggiornamento pacchetti e installazione strumenti"
apt update && apt upgrade -y
apt install -y dnsmasq hostapd iptables-persistent net-tools curl htop nload bridge-utils avahi-daemon docker.io

echo "[2/8] 🔁 Abilitazione forwarding IPv4"
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "[3/8] 🌐 Configurazione bridge LAN br0 (eth0 + wlan0)"
cat > /etc/network/interfaces.d/br0 <<EOF
auto br0
iface br0 inet static
  address 192.168.35.1
  netmask 255.255.255.0
  bridge_ports eth0 wlan0
EOF

echo "[4/8] 📡 Configurazione Wi-Fi Access Point (hostapd)"
mkdir -p /etc/hostapd
cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
bridge=br0
ssid=simonemessina
hw_mode=g
channel=6
wmm_enabled=1
auth_algs=1
wpa=2
wpa_passphrase=simonemessina.92
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

echo "[5/8] 📦 Configurazione DHCP e DNS (dnsmasq)"
cat > /etc/dnsmasq.conf <<EOF
interface=br0
dhcp-range=192.168.35.100,192.168.35.200,infinite
domain-needed
bogus-priv
EOF

echo "[6/8] 🔒 NAT da eth1 verso br0 (LAN/Wi-Fi)"
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

echo "[7/8] 🚀 Installazione CasaOS"
curl -fsSL https://get.casaos.io | bash

echo "[8/8] 🔄 Abilitazione e riavvio servizi"
systemctl enable dnsmasq
systemctl enable hostapd
systemctl enable docker
systemctl restart dnsmasq
systemctl restart hostapd
systemctl restart docker

echo ""
echo "✅ Setup COMPLETATO: AP 'simonemessina', IP 192.168.35.1, CasaOS attivo su porta 80"
echo "🔁 Riavvio in 10 secondi..."
sleep 10
reboot
