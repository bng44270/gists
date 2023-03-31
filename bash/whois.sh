#!/bin/bash

whoishost() {
	[[ -z "$1" ]] && echo "usage: whoishost <domain>" || (textback="$(nc $1 43 <<< "$2")" ; [[ -n "$(grep '^refer:' <<< "$textback")" ]] && whoishost $(awk '/^refer:/ { print $2 }' <<< "$textback") $2 || echo "$textback")
}

getargs() {
	echo "$@" | sed 's/[ \t]\+\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }'
}

[[ -n "$@" ]] && eval "$(getargs "$@")"

if [ -z "$ARG_s" ] || [ -z "$ARG_d" ]; then
	echo "usage: whois.sh -s <whois-server> -d <domain>"
else
	whoishost $ARG_s $ARG_d
fi
