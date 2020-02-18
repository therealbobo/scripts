#! /bin/bash

#DNS=1.1.1.1
MAIL_FROM="no_reply@bobo.com"
RCPT_TO="$1"
SUBJECT="$2"
BODY="$3"
MESSAGE="SUBJECT: $SUBJECT\n\n$3"
SMTP_PORT=25
SMTP_DOMAIN=${RCPT_TO##*@}

readarray -t RELAYS <<<$(dig +short MX $SMTP_DOMAIN | cut -d\  -f2) 
SMTP_COMMANDS=(
	"HELO $HOSTNAME"
	"MAIL FROM: <$MAIL_FROM>"
	"RCPT TO: <$RCPT_TO>"
	"DATA"
	"."
	"QUIT"
)

SMTP_REPLY=(
	[25]=OK
	[50]=FAIL
	[51]=FAIL
	[52]=FAIL
	[53]=FAIL
	[54]=FAIL
	[55]=FAIL
	[45]=WAIT
	[35]=DATA
	[22]=SENT
)

for RELAY in ${RELAYS[@]}; do
	SMTP_HOST="$RELAY"
	echo "Trying relay [$RELAY]: $SMTP_HOST..."
	exec 5<>/dev/tcp/$SMTP_HOST/$SMTP_PORT
	read -r HELO <&5
	echo GOT: $HELO
	for COMMAND_ORDER in {0..7}; do
		OUT=${SMTP_COMMANDS[COMMAND_ORDER]}
		echo SENDING: $OUT
		echo -e "$OUT\r" >&5
		read -r REPLY <&5
		echo REPLY: $REPLY
		# CODE=($REPLY)
		CODE=${REPLY:0:2}
		ACTION=${SMTP_REPLY[CODE]}
		case $ACTION in
			WAIT) echo Temporarily Fail
				break
				;;
			FAIL) echo Failed
				break
				;;
			OK) ;;
			SENT)exit 0
				;;
			DATA) echo Sending Message: $MESSAGE
				echo -ne "$MESSAGE" >&5
				echo -e "\r" >&5
				;;
			*) echo Unknown SMTP code $CODE
				exit 2
		esac
	done
done
