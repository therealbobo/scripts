#! /bin/bash


GW_ADDR="10.1.1.1/24"

ACTION=$1
AP_IFACE=$2
OUT_IFACE=$(ip -j r | jq -r '.[] | select(.dst=="default") | .dev')

if test "root" != $(whoami); then
	echo "Run as root!"
	exit -1
fi


if test "start" == $ACTION; then
	if test -z "$AP_IFACE"; then
		AP_IFACE=$OUT_IFACE
	fi
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

	iptables -t nat -A POSTROUTING -o $OUT_IFACE -j MASQUERADE
	echo "[+] Iptables setted!"

	ip addr add $GW_ADDR dev $AP_IFACE 
	systemctl restart dnsmasq
	systemctl restart hostapd
	echo "[+] Services restarted!"



elif test "stop" == $ACTION; then
	if test -z $AP_IFACE; then
		AP_IFACE=$(cat /tmp/ap)
	fi
	if test $AP_IFACE == $OUT_IFACE; then
		echo
	fi
	systemctl stop hostapd
	systemctl stop dnsmasq
	echo "[+] Services stopped!"

	iptables -t nat -D POSTROUTING -o $OUT_IFACE -j MASQUERADE
	echo "[+] Iptables setted!"

	ip addr del $GW_ADDR dev $AP_IFACE

	#setting ip forwarding
	sysctl -w net.ipv4.ip_forward=0
	echo "[+] Ip-forwarding disabled!"


	#setting ap_iface unmanaged
	nmcli device set $AP_IFACE managed yes
	echo "[+] $AP_IFACE managed!"

fi



