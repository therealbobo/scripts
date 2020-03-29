#! /bin/bash

UPSTREAM_IFACE=${1:-wlp2s0}

USB_IFACE=${2:-enp0s20f0u1i1}
USB_IFACE_IP=10.0.0.1
USB_IFACE_NET=10.0.0.0/24


nmcli device set $USB_IFACE managed no && echo "[+] Disabling annoying NetworkManager on $USB_IFACE" || (echo "[!] Cannot disable NetworkManager" ; exit -1 )

ip addr add "$USB_IFACE_IP/24" dev "$USB_IFACE" && echo "[+] IP of $USB_IFACE = $USB_IFACE_IP" || (echo "[!] Cannot set $USB_IFACE ip" ; exit -1 )
ip link set "$USB_IFACE" up && echo "[+] $USB_IFACE up and running!" || (echo "[!] Cannot set $USB_IFACE up" ; exit -1 )

echo '[-] Setting iptables...'
(iptables -A FORWARD -o "$UPSTREAM_IFACE" -i "$USB_IFACE" -s "$USB_IFACE_NET" -m conntrack --ctstate NEW -j ACCEPT && \
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT && \
iptables -t nat -F POSTROUTING && \
iptables -t nat -A POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE ) && echo "[+] iptables ok!" || (echo "[!] Cannot set iptables" ; exit -1 )

echo 1 > /proc/sys/net/ipv4/ip_forward
echo '[+] All done!'
