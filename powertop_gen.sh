#! /bin/bash


FILENAME="powertop.html"

sudo powertop -r $FILENAME
sed -n -e '/Software Settings in Need of Tuning/,$p' $FILENAME | sed '/Untunable/q' | grep 'class="tune"' | egrep -o 'echo.*;' | \
	while IFS=\' read _ VALUE _ DEV _; do
		echo w $DEV - - - - $VALUE
	done

rm $FILENAME
