#!/bin/bash

###############################
# checkciphers.sh
#      Check ciphers/protocols supported by a server running SSL/TLS
#      This relies on the capabilities of OpenSSL client machine
###############################

getfield() {
	if [ -z "$1" ]; then
		echo "usage: getfield <field-number> [<delimiter>]"
	else
		[[ -z "$2" ]] && DELIM=" " || DELIM="$2"
		awk -v FS="$DELIM" '{ print $'"$1"' }'
	fi
}

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "usage: checkciphers.sh <host> <port>"
else
	openssl ciphers -v | while read line; do
		CIPHER="$(getfield 1 <<<"$line")"
		PROTO="$(getfield 2 <<<"$line" | sed 's/\./_/g')"
		openssl s_client -cipher "$CIPHER" -$PROTO -connect $1:$2 < /dev/null 2>&1 | \
		awk 'BEGIN { 
			FS=":" 
		} 
		/^[ \t]*Cipher[ \t]*:/ { 
			if (match($2,/0000/)==0) {
				printf("* %s(%s): OK\n","'"$cipher"'",gensub(/_/,".","g",gensub(/^-/,"","g","'"$proto"'"))); 
			}
		}'
	done
fi
