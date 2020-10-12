#! /bin/bash

# A little script to fetch the timetable from Unibo

ANNO=2
CURRICULA=""
RECORD=false
ATTEND=false
DAY="today"
DEST_DIR='/run/mount/DATA/recordings'


function start_lesson(){
	URL=$1
	CODE=$2
	echo
	bspc rule -a Google-chrome desktop=^1
	bspc rule -a obs desktop=^10

	pkill picom
	nohup google-chrome-stable --start-fullscreen "$URL" >& /dev/null &
	nohup obs --startrecording >& /dev/null &
	OBS_PID=$!
	sleep 5
	echo '[.] Autojoin'
	start_teams_lesson.py
	echo '[.] Waiting obs'
	wait $OBS_PID
	REC=$(find $DEST_DIR -maxdepth 1 -type f)
	mv $REC $DEST_DIR/$CODE
	rclone -P sync $DEST_DIR/$CODE onedrive_uni:$CODE
	echo '[+] All done'
	picom -b &
}

function attend(){
	URL=$1
	CODE=$2
	echo
	bspc rule -a Google-chrome desktop=^1

	nohup google-chrome-stable --start-fullscreen "$URL" >& /dev/null &
	sleep 5
	echo '[.] Autojoin'
	start_teams_lesson.py
}

function get_timetable(){
	API=$1
	curl -s "$API" \
		-H 'cookie: unibo_cookie_consent=yes' | \
		jq -c '.[]' | \
		jq -cr '[.time , .title, .teams, .cod_modulo] | @csv' | \
		tr -d '"'
}

while getopts "arhd:" options; do
	case "${options}" in
		a)
			ATTEND=true
			break
			;;
		r)
			RECORD=true
			break
			;;
		d)
			DAY=${OPTARG}
			break
			;;
		h)
			echo "Usage: $0 (-r|-h|-d <date>)
	-h	print this help message
	-d	choose a day
	-a	attend the lesson
	-r	start recording"
			exit 0
			;;
		*)
			;;
	esac
done

CURRENT_LESSONS=()
DATE=$(date --iso-8601 --date="$DAY")
API="https://corsi.unibo.it/magistrale/ingegneriainformatica/orario-lezioni/@@orario_reale_json?anno=${ANNO}&curricula=${CURRICULA}&start=${DATE}&end=${DATE}"

echo 'Schedule       Subject' 
while IFS=',' read SCHEDULE SUBJECT URL CODE; do
	START=$(echo $SCHEDULE | sed 's/://g' | awk '{print $1}' | sed 's/^0*//g')
	END=$(  echo $SCHEDULE | sed 's/://g' | awk '{print $3}' )
	START=$((START - 50))
	CURRENT=$(date +%H%M)
	if [ -n "$URL" -a $CURRENT -ge $START -a $CURRENT -le $END ] ; then
		CURRENT_LESSONS+=("$SUBJECT;$URL;$CODE")
	fi
	echo "$SCHEDULE  ${SUBJECT:0:32}"
done < <(get_timetable $API)

if $RECORD ; then
	if [ ${#CURRENT_LESSONS[@]} -gt 1 ]; then
		echo
		i=0
		for LESSON in "${CURRENT_LESSONS[@]}" ; do
			IFS=\; read SUBJECT URL CODE < <(echo $LESSON) 
			echo "[$i] $SUBJECT"
			i=$((i + 1))
		done
		echo -n 'Select the lesson you want to record: '
		read k
		IFS=\; read SUBJECT URL CODE < <(echo "${CURRENT_LESSONS[$k]}") 
		start_lesson "$URL" "$CODE"
	else
		IFS=\; read _ URL CODE < <(echo "${CURRENT_LESSONS[0]}") 
		start_lesson "$URL" "$CODE"
	fi
fi

if $ATTEND ; then
	if [ ${#CURRENT_LESSONS[@]} -gt 1 ]; then
		echo
		i=0
		for LESSON in "${CURRENT_LESSONS[@]}" ; do
			IFS=\; read SUBJECT URL CODE < <(echo $LESSON) 
			echo "[$i] $SUBJECT"
			i=$((i + 1))
		done
		echo -n 'Select the lesson you want to attend: '
		read k
		IFS=\; read SUBJECT URL CODE < <(echo "${CURRENT_LESSONS[$k]}") 
		attend "$URL" "$CODE"
	else
		IFS=\; read _ URL CODE < <(echo "${CURRENT_LESSONS[0]}") 
		attend "$URL" "$CODE"
	fi
fi
