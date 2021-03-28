#! /bin/sh

# always run as root
[ "$(id -u)" != 0 ] && {
	sudo "$0";
	exit
}

URL="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip"

cd /etc/openvpn || exit 1

curl -LO $URL
rm -rf ovpn_*
unzip -q ovpn.zip
rm ovpn.zip

cd - || exit 1
