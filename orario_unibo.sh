#! /bin/bash

# A little script to fetch the timetable from Unibo

ANNO=1
CURRICULA=""
RECORD=1
DAY="today"

API="https://corsi.unibo.it/magistrale/ingegneriainformatica/orario-lezioni/@@orario_reale_json?anno=${ANNO}&curricula=${CURRICULA}"

function start_lesson(){
	echo
	bspc rule -a Google-chrome desktop=^1
	bspc rule -a obs desktop=^10

	nohup google-chrome-stable --start-fullscreen "$1" >& /dev/null &
	nohup obs --startrecording >& /dev/null &
}

while getopts "rhd:" options; do
	case "${options}" in
		r)
			RECORD=0
			break
			;;
		d)
			DAY=${OPTARG}
			break
			;;
		h)
			echo "Usage: $0 (-r|-h|<date>)
	-h	print this help message
	-d	choose a day
	-r	start recording"
			exit 0
			;;
		*)
			;;
	esac
done

DATE=$(date --iso-8601 --date="$DAY")

curl -s "$API" \
	-H 'cookie: unibo_cookie_consent=yes' | \
	jq -c '.events | .[]' | \
	grep "$DATE" | \
	jq -cr '[.time , .title, .teams] | @csv' | \
	tr -d '"' | \
	while IFS=',' read SCHEDULE SUBJECT URL; do
		START=$(echo $SCHEDULE | sed 's/://g' | awk '{print $1}' | sed 's/^0*//g')
		END=$(  echo $SCHEDULE | sed 's/://g' | awk '{print $3}' )
		START=$((START - 50))
		CURRENT=$(date +%H%M)
		[ $RECORD == 0 -a $CURRENT -ge $START -a $CURRENT -le $END ] \
			&& start_lesson "$URL"
		echo "$SCHEDULE,${SUBJECT:0:32}"
	done | \
	column -t -s\, -N 'Schedule,Subject'
