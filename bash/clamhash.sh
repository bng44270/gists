#!/bin/bash

usage() {
	echo "usage: clamhash.sh [ -f <cvd-file> | -d <cvd-daily-or-main>] -h <hash>"
}

getargs() {
	[[ -z "$1" ]] && echo "usage: getargs <arguments>" || echo "$@" | sed 's/\(-[a-zA-Z] \)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/\n/,"","g",gensub(/^-/,"","g",$1)),length($2)==0?"EMPTY":gensub(/\n/,"","g",$2)) }'
}

[[ -n "$@" ]] && eval "$(getargs "$@")"

if [ -z "$ARG_f" ] && [ -z "$ARG_d" ] && [ -z "$ARG_h" ]; then
	usage
else
	if [ -n "$ARG_f" ] && [ -f $ARG_f ] && [ -n "$ARG_h" ]; then
		cat $ARG_f | \
		xxd -ps -s 512 | xxd -r -ps | \
		tar -xzO daily.hdb | \
		awk 'BEGIN {
			FS=":" 
			printf("%-40s%8s   %s\n","Name","Size","Hash")
		} 
		/'"$ARG_h"'/{
			printf("%-40s%8s   %s",$3,$2,$1)
		}'
	elif [ -n "$ARG_d" ] && [ -n "$ARG_h" ]; then
		if [ -n "$(egrep '^main$|^daily$' <<< "$ARG_d")" ] && [ -n "$2" ]; then
			curl -s http://database.clamav.net/$ARG_d.cvd | \
			xxd -ps -s 512 | xxd -r -ps | \
			tar -xzO daily.hdb | \
			awk 'BEGIN {
				FS=":" 
				printf("%-40s%8s   %s","Name","Size","Hash")
			} 
			/'"46efe282b9b82c82bad83b83bc7d8c96"'/{
				printf("%-40s%8s bytes   %s\n",$3,$2,$1)
			}'
		else
			echo "Invalid option and/or hash ($@)"
		fi
	else
		echo "Invalid Arguments"
		usage
	fi
fi
