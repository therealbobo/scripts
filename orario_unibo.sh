#! /bin/bash

# A little script to fetch the timetable from Unibo

ANNO=1
CURRICULA=""
RECORD=1

API="https://corsi.unibo.it/magistrale/ingegneriainformatica/orario-lezioni/@@orario_reale_json?anno=${ANNO}&curricula=${CURRICULA}"
DAY=${1:-today}
DATE=$(date --iso-8601 --date="$DAY")

function start_lesson(){
	bspc rule -a Google-chrome desktop=^1
	bspc rule -a obs desktop=^10

	nohup google-chrome-stable --start-fullscreen "$1" >& /dev/null &
	nohup obs --startrecording >& /dev/null &
}

while getopts "rh" options; do
	case "${options}" in
		r)
			RECORD=0
			break
			;;
		h)
			echo "Usage: $0 (-r|-h|<date>)
	-h	print this help message
	-r	start recording"
			exit 0
			;;
		*)
			;;
	esac
done

curl -s "$API" \
	-H 'cookie: unibo_cookie_consent=yes' | \
	jq -c '.events | .[]' | \
	grep "$DATE" | \
	jq -cr '[.time , .title, .teams] | @csv' | \
	tr -d '"' | \
	while IFS=',' read SCHEDULE SUBJECT URL; do
		START=$(echo $SCHEDULE | awk -F'(:|-| )' '{print $1}')
		END=$(  echo $SCHEDULE | awk -F'(:|-| )' '{print $5}')
		CURRENT=$(date +%H)
		[ $RECORD == 0 -a $CURRENT -ge $START -a $CURRENT -le $END ] \
			&& start_lesson "$URL"
		echo "$SCHEDULE,${SUBJECT:0:32}"
	done | \
	column -t -s\, -N 'Schedule,Subject'
