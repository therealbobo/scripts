#! /bin/bash

# A little script to fetch the timetable from Unibo

ANNO=1
CURRICULA=""

API="https://corsi.unibo.it/magistrale/ingegneriainformatica/orario-lezioni/@@orario_reale_json?anno=${ANNO}&curricula=${CURRICULA}"
DAY=${1:-today}
DATE=$(date --iso-8601 --date="$DAY")

curl -s "$API" \
	-H 'cookie: unibo_cookie_consent=yes' | \
	jq -c '.events | .[]' | \
	grep "$DATE" | \
	jq -cr '[.time , .title] | @csv' | \
	tr -d '"' | \
	while IFS=',' read SCHEDULE SUBJECT ; do
		echo "$SCHEDULE,${SUBJECT:0:32}"
	done | \
	column -t -s\, -N 'Schedule,Subject'
