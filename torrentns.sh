#! /bin/sh

# always run as root
[ "$(id -u)" != 0 ] && {
	sudo "$0" $*
	exit 0
}

NS='vpn0'
GROUP='vpnroute'
EXEC="ip netns exec $NS"
#W_GROUP="sudo -g $GROUP"
OVPN_PIDF='/tmp/ovpn.pid'

case $1 in
	up)
		pgrep openvpn && killall openvpn

		# add virtual interfaces
		ip link add veth0 type veth peer name veth1

		# add namespace
		ip netns add $NS

		# link vif to namespace
		ip link set veth1 netns $NS
		ip addr add 10.10.1.1/24 dev veth0 

		# internal to namespace vif up
		$EXEC ip link set veth1 up
		ip link set veth0 up

		# add working ip to namespace vif
		$EXEC ip addr add 10.10.1.2/24 dev veth1

		# routing in namespace
		$EXEC ip route add default via 10.10.1.1 dev veth1

		mkdir -p /etc/netns/$NS
		echo 'nameserver 1.1.1.1' | tee /etc/netns/$NS/resolv.conf

		sysctl -w net.ipv4.ip_forward=1

		# antispoofing
		iptables -A INPUT -i eth0 -s 10.10.1.0/24 -j DROP

		iptables -t nat -A PREROUTING \
			-p tcp \
			-i eth0 \
			--dport 9091 \
			-j DNAT \
			--to-destination 10.10.1.2:9091

		iptables -A FORWARD \
			-p tcp \
			-m state --state NEW,ESTABLISHED,RELATED \
			-s 192.168.1.0/24 \
			-d 192.168.1.10 \
			-i eth0 \
			-o veth0 \
			-j ACCEPT

		iptables -t nat -A POSTROUTING \
			-p tcp \
			-j MASQUERADE

		$EXEC iptables -A OUTPUT \
			-m owner \
			--gid-owner vpnroute \
			-d 10.10.1.1 \
			-o veth1 \
			-j ACCEPT

		$EXEC iptables -A OUTPUT \
			-m owner \
			--gid-owner vpnroute \
			\! -o tun0 \
			-j REJECT

		[ -f "$OVPN_PIDF" ] && rm $OVPN_PIDF
		#SERVER=$(/home/robi/.local/bin/shuff_nordvpn.sh)
		SERVER=it205.nordvpn.com.tcp.ovpn
		TRANSMISSION_SCRIPT='/home/robi/.local/bin/torrentmanage.sh'
		$EXEC openvpn \
			--config /etc/openvpn/ovpn_tcp/${SERVER} \
			--auth-user-pass /etc/openvpn/auth \
			--script-security 2 \
			--route-up "$TRANSMISSION_SCRIPT" \
			--route-pre-down "$TRANSMISSION_SCRIPT" \
			--writepid "$OVPN_PIDF" \
			--daemon
		;;
	down)

		iptables -D INPUT -i eth0 -s 10.10.1.0/24 -j DROP

		iptables -t nat -D PREROUTING \
			-p tcp \
			-i eth0 \
			--dport 9091 \
			-j DNAT \
			--to-destination 10.10.1.2:9091

		iptables -D FORWARD \
			-p tcp \
			-m state --state NEW,ESTABLISHED,RELATED \
			-s 192.168.1.0/24 \
			-d 192.168.1.10 \
			-i eth0 \
			-o veth0 \
			-j ACCEPT

		iptables -t nat -D POSTROUTING \
			-p tcp \
			-j MASQUERADE

		$EXEC iptables -D OUTPUT \
			-m owner \
			--gid-owner vpnroute \
			-d 10.10.1.1 \
			-o veth1 \
			-j ACCEPT

		$EXEC iptables -D OUTPUT \
			-m owner \
			--gid-owner vpnroute \
			\! -o tun0 \
			-j REJECT


		[ -f "$OVPN_PIDF" ] && kill "$(cat $OVPN_PIDF)"
		pgrep transmission-daemon && killall transmission-daemon
		ip link set veth0 down
		ip link del veth0
		ip netns delete $NS
		;;
	*)
		echo "Usage: $0 up|down"
		;;
esac
