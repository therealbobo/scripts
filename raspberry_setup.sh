#! /bin/bash

IFACE=$(ip a | egrep enp | awk -F "(:| )" '{print $3}')
HOST_IFACE="wlp2s0"
HOST_IP="192.168.7.1"
PI_IP="192.168.7.2"
USER="pi"
DNS="1.1.1.1" 
HOST_USER="robi"

if test $# -eq 1; then
	if $(ip a | grep -q $1); then
		HOST_IFACE=$1
	else
		exit -1
	fi
fi


#set iface unmanaged
nmcli device set $IFACE managed no

#setup static ip
ip address add $HOST_IP scope link dev $IFACE
ip route add $PI_IP src $HOST_IP scope link dev $IFACE

#set iptables rules
iptables -F
iptables -t nat -F
iptables -A FORWARD -i $IFACE -j ACCEPT
iptables -t nat -A POSTROUTING -o $HOST_IFACE -j MASQUERADE
echo 1 | tee /proc/sys/net/ipv4/ip_forward

#ssh
#ssh $USER@$PI_IP "echo nameserver $DNS | sudo tee /etc/resolv.conf"
sudo -i -u $HOST_USER ssh $USER@$PI_IP

