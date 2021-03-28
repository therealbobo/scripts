#! /bin/sh

ajax_request(){

	# ACTIONS
	# servers_countries
	# servers_groups
	# servers_technologies
	# servers_recommendations

	PARAMS="action=$1"
	[ -n "$2" ] && PARAMS="$PARAMS&filters=$2"

	curl "https://nordvpn.com/wp-admin/admin-ajax.php?$PARAMS"\
	  -H 'authority: nordvpn.com' \
	  -H 'pragma: no-cache' \
	  -H 'cache-control: no-cache' \
	  -H 'accept: */*' \
	  -H 'dnt: 1' \
	  -H 'x-requested-with: XMLHttpRequest' \
	  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36' \
	  -H 'sec-fetch-site: same-origin' \
	  -H 'sec-fetch-mode: cors' \
	  -H 'sec-fetch-dest: empty' \
	  -H 'referer: https://nordvpn.com/it/servers/tools/' \
	  -H 'accept-language: it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5,ru;q=0.4' \
	  --compressed -s
}


p2p(){

	COUNTRY=$1
	# tcp
	SERVER_TECH=5
	# p2p
	SERVER_GROUP=15

	ajax_request servers_recommendations "\{%22country_id%22:$COUNTRY,%22servers_groups%22:\[$SERVER_GROUP\],%22servers_technologies%22:\[$SERVER_TECH\]\}"
}


# find random server
while true; do
	COUNTRY=$(ajax_request servers_countries | jq '.[].id' | grep it | shuf -n1) #| shuf -n1)
	RESULT=$(p2p "$COUNTRY")
	[ "$RESULT" != '[]' ] && break
done

echo "$RESULT" | jq -r '.[].hostname' | shuf -n1

