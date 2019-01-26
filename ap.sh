#! /bin/bash

ACTION=$1
AP_IFACE=$2

if test "root" != $(whoami); then
	echo "Run as root!"
	exit -1
fi


if test "start" == $ACTION; then
	echo "$AP_IFACE" > /tmp/ap
	#setting ap_iface unmanaged
	nmcli device set $AP_IFACE managed no
	echo "[+] $AP_IFACE unmaneged!"

	#setting hostapd interface
	sed -ie "s/interface=.*/interface=$AP_IFACE/" /etc/hostapd/hostapd.conf
	#setting dnsmasq interface
	sed -ie "s/interface=.*/interface=$AP_IFACE/" /etc/dnsmasq.conf
	echo "[+] Configuration files edited!"

	#setting ip forwarding
	sysctl -w net.ipv4.ip_forward=1
	echo "[+] Ip-forwarding enabled!"

	iptables -t nat -A POSTROUTING -o wlp2s0 -j MASQUERADE
	echo "[+] Iptables setted!"

	ip addr add 10.1.1.1/24 dev $AP_IFACE

	systemctl restart dnsmasq
	systemctl restart hostapd
	echo "[+] Services restarted!"



elif test "stop" == $ACTION; then
	if test -z $AP_IFACE; then
		AP_IFACE=$(cat /tmp/ap)
	fi
	systemctl stop hostapd
	systemctl stop dnsmasq
	echo "[+] Services stopped!"

	iptables -t nat -D POSTROUTING -o wlp2s0 -j MASQUERADE
	echo "[+] Iptables setted!"

	ip addr del 10.1.1.1/24 dev $AP_IFACE

	#setting ip forwarding
	sysctl -w net.ipv4.ip_forward=0
	echo "[+] Ip-forwarding disabled!"


	#setting ap_iface unmanaged
	nmcli device set $AP_IFACE managed yes
	echo "[+] $AP_IFACE managed!"

fi



