#! /bin/bash


function send_mail(){
	IP=$1
	HOSTNAME=$(hostname)
	#DEST=$(cat "$HOME"/.conf/ip_sender.conf)
	SUBJECT="$HOSTNAME new IP"
	BODY="$IP"
	source "$HOME"/.config/ip_sender.conf
	$HOME/scripts/mail_sender.sh "$DEST" "$SUBJECT" "$BODY"

}

OLD_IP=""
CUR_IP=$(curl -fSs https://1.1.1.1/cdn-cgi/trace | sed -n 's/^ip=\(.*\)/\1/p')

[ -f /tmp/ip ] && OLD_IP=$(cat /tmp/ip)

if [[ $CUR_IP != $OLD_IP ]] ; then
	echo $CUR_IP > /tmp/ip
	send_mail $CUR_IP
fi


