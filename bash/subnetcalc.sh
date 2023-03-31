#!/bin/bash

################
# subnetcalc.sh
#
# Calculate host bits, network bits, 
# and host count from subnet mask
#
################

if [ -z "$@" ]; then
	echo "usage: subnetcalc.sh <subnet-mask>"
	echo "     calculate the bit length of a subnet given the mask"
else
	echo "$@" | awk 'BEGIN { RS="." } { print $1 }' | grep -v 255 | while read line; do 
		if [ $line -eq 0 ]; then 
			echo "8"
		else
			echo "obase=2;$line" | bc | sed 's/^1*//g' | tr -d '\n' | wc -c
		fi
	done | awk 'BEGIN { tot=0 } { tot=tot+$1 } END { hostcount=(2^tot)-2; net=32-tot; printf("%-15s%s\n%-15s%s\n%-15s%s\n","Host Bits:",tot,"# of Hosts:",hostcount,"Network Bits:",net); }'
fi