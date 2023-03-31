#!/bin/bash

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ ! -f $ARG_k ] && [ -z "$ARG_u" ]; then
	echo "usage: ssh-keyconn.sh -k <private-key> -u <user@host>"
else
	SSHPID="$(eval $(ssh-agent -s) | sed 's/^.*[ \t]\+\([0-9]\+\)$/\1/g')"
	ssh-add $ARG_k
	ssh $ARG_u
	kill -9 $SSHPID
fi
