#!/bin/bash

#######################################################
#
# Calculate IP Network Scheme
#
# Usage:
#
#    ipcalc.sh <cidr-notation>
#
#     <cidr-notation> - <ip-address>/<bit-mask>
#
#     Ex.  
#
#          $ ipcalc.sh 192.168.1.100/24
#          Network:            192.168.1.0/24
#          First IP:           192.168.1.1
#          Last IP:            192.168.1.254
#          Subnet Mask:        255.255.255.0
#          Broadcast Address:  192.168.1.255
#          Host Count:         254
#
#
#######################################################

_build_net_mask() {
	(
		for i in $(seq 1 $1); do 
			printf "1"
		done
		
		z="$((32-$1))"
		
		for i in $(seq 1 $z); do
			printf "0"
		done
		
		echo ""
	) | sed 's/\([01]\{8\}\)/\1\n/g' | grep -v '^$' | while read line; do
		echo $((2#$line))
	done
}

_validate_ip() {
	if [ $1 -gt 0 ] && [ $1 -lt 256 ] && [ $2 -gt 0 ] && [ $2 -lt 256 ] && [ $3 -gt 0 ] && [ $3 -lt 256 ] && [ $4 -gt 0 ] && [ $4 -lt 256 ]; then
		echo "0"
	else
		echo "1"
	fi
}

if [ -n "$1" ]; then
	CIDR="$@"
	IP="$(sed 's/\/[0-9]\+//g' <<< "$CIDR")"
	MASK="$(sed 's/^.*\///g' <<< "$CIDR")"
	
	OCTETS="$(awk -F '.' '{print NF}' <<< "$IP")"
	
	if [ $MASK -gt 0 ] && [ $MASK -lt 33 ] && [ $OCTETS -eq 4 ]; then		
		IPAR=()
		IPAR[0]="$(awk 'BEGIN { FS="." } { print $1 }' <<< "$IP")"
		IPAR[1]="$(awk 'BEGIN { FS="." } { print $2 }' <<< "$IP")"
		IPAR[2]="$(awk 'BEGIN { FS="." } { print $3 }' <<< "$IP")"
		IPAR[3]="$(awk 'BEGIN { FS="." } { print $4 }' <<< "$IP")"
	
		if [ $(_validate_ip ${IPAR[@]}) -eq 1 ]; then
			echo "Invalid IP Address"
			exit 1
		fi
		
		MASKAR=()
		
		for octet in $(_build_net_mask $MASK); do
			MASKAR+=($octet)
		done
		
		LOWADDR=()
		UPRADDR=()
		BRDADDR=()
		NETADDR=()
		
		for i in $(seq 0 3); do
			ADR=$(( ${MASKAR[$i]} & ${IPAR[$i]} ))
			
			if [ $ADR -eq 0 ]; then
				if [ $i -eq 3 ]; then
					UPRADDR+=("254")
					LOWADDR+=("1")
					BRDADDR+=("255")
					NETADDR+=("0")
				else
					UP=$(( ${MASKAR[$i]} ^ 255 ))
					UPRADDR+=($(($UP + $ADR)))
					LOWADDR+=($ADR)
					BRDADDR+=($(($UP + $ADR)))
					NETADDR+=($ADR)
				fi
			elif [ $ADR -eq 255 ]; then
				if [ $i -eq 3 ]; then
					UPRADDR+=("254")
					LOWADDR+=("254")
					BRDADDR+=("255")
					NETADDR+=($ADR)
				else
					UP=$(( ${MASKAR[$i]} ^ 255 ))
					UPRADDR+=($(($UP + $ADR)))
					LOWADDR+=($ADR)
					BRDADDR+=($(($UP + $ADR)))
					NETADDR+=($ADR)
				fi
			else
				UP=$(( ${MASKAR[$i]} ^ 255 ))
				UPRADDR+=($(($UP + $ADR)))
				LOWADDR+=($ADR)
				BRDADDR+=($(($UP + $ADR)))
					NETADDR+=($ADR)
			fi
		done
		
		printf "Network:            "
		echo "${NETADDR[@]}/$MASK" | sed 's/[ \t]\+/./g'
		
		printf "First IP:           "
		echo "${LOWADDR[@]}" | sed 's/[ \t]\+/./g'
		
		printf "Last IP:            "
		echo "${UPRADDR[@]}" | sed 's/[ \t]\+/./g'
		
		printf "Subnet Mask:        "
		echo "${MASKAR[@]}" | sed 's/[ \t]\+/./g'
		
		printf "Broadcast Address:  "
		echo "${BRDADDR[@]}" | sed 's/[ \t]\+/./g'
		
		printf "Host Count:         "
		bc <<< "(2^(32-$MASK))-2" | rev | sed 's/\([0-9]\{3\}\)/\1,/g;s/,$//g' | rev
	else
		echo "Invalid CIDR notation"
	fi
else
	echo "calc <cidr-notation>"
fi