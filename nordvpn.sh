#! /bin/bash


TARGET=it
PROTO=tcp
DIR=/etc/openvpn
AUTH=/etc/openvpn/auth.txt

ENDPOINTS=($(ls $DIR/ovpn_$PROTO/$TARGET*))
SIZE=${#ENDPOINTS[@]}

function test_server(){
	IP=$(  cat $1 | egrep '^remote ' | cut -d' ' -f2)
	PORT=$(cat $1 | egrep '^remote ' | cut -d' ' -f3)
	tput setaf 3
	echo "[-] Testing $IP"
	tput sgr0
	! (nmap $IP -p $PORT |  grep -q -e "Host seems down" -e "closed") && return 0
	return 1
}

while :
do
	INDEX=$(($RANDOM % $SIZE))
	SERVER=${ENDPOINTS[$INDEX]}
	(test_server $SERVER) && break
	tput setaf 1
	echo "[!] $SERVER not reachable"
	tput sgr0
done

tput setaf 2
tput bold
echo "[+] $SERVER seems ok!"
tput sgr0
sudo openvpn --config $SERVER --auth-user-pass $AUTH
