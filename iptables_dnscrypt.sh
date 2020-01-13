#! /bin/bash

function flush_iptables_nat(){
	iptables -t nat -F
	ip6tables -t nat -F
}


iptables -t nat -F
ip6tables -t nat -F


FALLBACK_SERVERS=("1.1.1.1" "8.8.8.8" "137.204.25.71" "10.192.168.1")
#FALLBACK_SERVERS=("1.1.1.1" "8.8.8.8")
FALLBACK=""


for SERVER in ${FALLBACK_SERVERS[@]}; do
	echo "[ ] Testing $SERVER"
	if $(nslookup -timeout=2 "google.com" $SERVER | grep -q "connection timed out"); then
		echo "[-] $SERVER cannot be reached!"
	else
		echo "[+] $SERVER can be reached! Setting up IpTables"
		FALLBACK=$SERVER
		break
	fi
done

iptables -t nat -A OUTPUT -p udp --dport 5301 -j DNAT --to $FALLBACK:53 2>&1

iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 127.0.0.1:5300 2>&1
iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 127.0.0.1:5300 2>&1
ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to [::1]:5300 2>&1
ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to [::1]:5300 2>&1

systemctl start dnscrypt-proxy.service
