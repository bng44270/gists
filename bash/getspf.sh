#!/bin/bash

######################################
#
# getsph.sh - get recursive Sender Policy Framework (SPF) data for a given domain
#
# usage: getspf.sh <domain-name>
#
######################################

if [ -z $1 ]; then
  echo "getspf.sh <domain-name>"
else
  dig $1 txt | grep "^$1" | sed 's/^.*TXT[\t]*"//g;s/"$//g' | tr ' ' '\n' | while read line; do
    if [[ $line =~ ^ip ]]; then
      echo $line | sed 's/^ip.*://g'
    elif [[ $line =~ ^ptr ]]; then
      echo $line | sed 's/ptr://g'
    elif [[ $line =~ ^include ]]; then
      $0 $(echo $line | sed 's/^include://g')
    elif [[ $line =~ ^redirect ]]; then
      $0 $(echo $line | sed 's/^redirect=//g')
    else
      continue
    fi
  done
fi