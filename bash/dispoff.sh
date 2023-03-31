#!/bin/bash

getargs() {
  [[ -z "$1" ]] && echo "usage: getargs <arguments>" || echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ -z "$ARG_d" ] && [ -z "$ARG_o" ]; then
  echo "usage:  dispoff.sh -d <detect-display> -o <off-display>"
else
  DETECTED="$(xrandr | grep "^$ARG_d")"
  if [ -n "$DETECTED" ]; then
    xrandr --output $ARG_o --off
  fi
fi		