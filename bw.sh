#! /bin/bash

set -eu
set -o pipefail

FILE=/tmp/.bw

[ ! -f $FILE ] \
	&& export BW_SESSION=$(echo -n '? Master password: ' 1>&2 ; bw unlock 2>&1 | grep 'export BW_SESSION=' | cut -d\" -f2) \
	|| export BW_SESSION=$(cat $FILE)
[ ! -z $BW_SESSION ] && echo $BW_SESSION > $FILE && \
bw list items \
	| jq -er '.[]|[(.login.username, .name), (.login.uris[0]? | .uri),(.id)] | @tsv' \
	| awk '{split($3, tmp, "://"); split(tmp[2], b, "/"); print $1,$2, b[1],"~"$4}' \
	| fzf -i -d '~' --with-nth=1 --reverse --preview 'bw get item {2} | jq | grep -v password' \
	| cut -d\~ -f2 \
	| xargs bw get item \
	| jq -er '.login.password' \
	| xclip -sel clipboard
