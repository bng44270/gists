#!/bin/bash

######################
# sshahash.sh
#
#    Generates Salted SHA (SSHA) hashes
#
# This uses an implementation of the packhex function (https://gist.github.com/bng44270/e10f23c579134129bafe)
# to convert a string containing hexidecimal characters into binary data
#
# usage: sshahash.sh <text>
#
######################

packhex() {
  strlen=`printf "$1" | wc -c`
  hexstring=""
  evenword=`echo "$strlen % 4" | bc | grep '0'`
  if [ ${#evenword} -eq 0 ]; then
    upperwordlen=`echo "$strlen % 4" | bc`
    padlen=`echo "4-$upperwordlen" | bc`
    wordpad=`printf "%0${padlen}d"`
    hexstring="$wordpad$1"
    strlen=`printf "$hexstring" | wc -c`
  else
    hexstring="$1"
  fi

  idx="0"

  while true; do
    if [ $idx -lt $strlen ]; then
      hexword=`printf "${hexstring:$idx:4}"`
      printf \\x"${hexword:0:2}"
      printf \\x"${hexword:2:2}"
      idx=`echo $idx+4 | bc`
    else
      break
    fi
  done
}

if [ -z "$1" ]; then
  echo "usage:  sshahash <password-text>"
else
  curstamp=`date +%s`
  salt=`echo "$curstamp + ($curstamp % 10)" | bc`
  shahash=`printf "$1$salt" | openssl sha1 | sed 's/(stdin)= //g'`

  printf "{SSHA}"
  
  (
    packhex "$shahash"
    printf "$salt"
  ) | base64
fi
