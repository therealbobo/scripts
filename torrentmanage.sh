#! /bin/sh

# always run as root
#[ $(id -u) != 0 ] && sudo "$0" $* && exit

NS='vpn0'
GROUP='vpnroute'
EXEC="ip netns exec $NS"
W_GROUP="sudo -g $GROUP"


case $script_type in
	route-up)
		$EXEC $W_GROUP transmission-daemon \
			--config-dir /etc/transmission-daemon
		;;
	route-pre-down)
		killall transmission-daemon
		;;
esac
