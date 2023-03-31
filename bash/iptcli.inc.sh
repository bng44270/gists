##############################################
#
# iptcli.rc - Bash resoruce file to facilitate iptables auto-complete interface
#
# Usage:
#
#    1. Create iptcli alias:
#
#        alias iptcli="bash --rcfile /path/to/.iptcli.rc"
#    
#    2. Open CLI:
#
#        iptcli
#
#    3. Use the built in 'help' commands
#
##############################################

BASEDIR="$HOME/.iptcli"
[[ ! -d $BASEDIR ]] && /usr/bin/mkdir $BASEDIR
cd $BASEDIR

PATH=""
HISTFILE="~/.iptcli_history"
HISTTIMEFORMAT="%m/%d/%Y %H:%M:%S "

PS1="iptables > "

hash -p /usr/bin/grep grep
hash -p /usr/bin/sed sed
hash -p /usr/bin/awk awk
hash -p /usr/bin/cat cat
hash -p /usr/bin/wc wc
hash -p /usr/bin/clear clear
hash -p /usr/sbin/iptables iptables
hash -p /usr/sbin/iptables-save iptables-save
hash -p /usr/bin/iptables-xml iptables-xml
hash -p /usr/sbin/ifconfig ifconfig
hash -p /usr/bin/netstat netstat
hash -p /usr/bin/netcat netcat
hash -p /usr/bin/ping ping
hash -p /usr/bin/tcpdump tcpdump
hash -p /usr/bin/chmod chmod
hash -p /usr/bin/seq seq
hash -p /usr/bin/bc bc
hash -p /usr/bin/rev rev
hash -p /usr/bin/traceroute traceroute
hash -p /usr/bin/dig dig

alias help="_iptcli_help"

IPT_TABLES=(nat filter mangle raw security)

_iptcli_help() {
	echo "Available tables:"
	for TAB in ${IPT_TABLES[@]}; do
		echo "   $TAB"
	done
	echo ""
	echo "Syntax:"
	echo "   <table> <action> [<chain>] [<option>] [<format>]"
	echo ""
	echo "   <action> = append|check|delete|insert|replace|list|flush|zero|newchain|delchain|dump*"
	echo "   <option> = interface|protocol|source|destination|match|destport|jump"
	echo "   <format> = raw|xml (used for \"dump\" only"
	echo ""
	echo "Other commands:"
	echo "   iface <list | up | down | ipv4 | ipv6> [<interface> | all]"
	echo "      all = only used for list"
	echo ""
	echo "   connection [list | test] [<list-opts> | <test-opts>]"
	echo "      list-opts = tcp tcp6 udp udp6 multicast"
	echo "      test-opts = destaddr destport timeout"
	echo ""
	echo "   traffic [stats | capture] [list] interface <ifname> [file <filename>]"
	echo "      file = only used for capture"
	echo "      list = only used for capture"
	echo ""
	echo "   trace hops <hop-count> addr <hostname/IP>"
	echo ""
	echo "   lookup host <hostname> type <DNS-record-type>"
	echo ""
	echo "   calc <cidr-notation>"
	echo "   ping <address>"
	echo "   contains <expression>"
	echo "   column <number>"
	echo "   count <expression>"
	echo ""
}

_iptcli_backend() {
	if [ -n "$1" ]; then
		if [ -n "$(/usr/bin/grep "dump[ \t]*$" <<< "$@")" ]; then
			iptables-save -t $1 | grep '^-' | sed 's/-A /append /;
				s/ -I / insert /;
				s/ -i / ifin /;
				s/ -o / ifout /;
				s/ -p / protocol /;
				s/ -s / source /;
				s/ -d / destination /;
				s/ -m comment --comment / comment /;
				s/ -m / match /;
				s/ --dport / destport /;
				s/ -j / jump /;
				s/ -n / noresolve /'
		elif [ -n "$(/usr/bin/grep "dump xml$" <<< "$@")" ]; then
			iptables-save -t $1 | iptables-xml
		elif [ -n "$(/usr/bin/grep "dump raw$" <<< "$@")" ]; then
			iptables-save -t $1
		else
			iptables $(sed '
				s/^/-t /;
				s/ comment / -m comment --comment /;
				s/ append / -A /;
				s/ check / -C /;
				s/ delete / -D /;
				s/ insert / -I /;
				s/ replace / -R /;
				s/ list[ ]*/ -L /;
				s/ noresolve[ ]*/ -n /;
				s/ flush / -F /;
				s/ zero / -Z /;
				s/ newchain / -N /;
				s/ delchain / -X /;
				s/ ifin / -i /;
				s/ ifout / -o /;
				s/ protocol / -p /;
				s/ source / -s /;
				s/ destination / -d /;
				s/ match / -m /;
				s/ destport / --dport /;
				s/ jump / -j / 
			' <<< "$@")
		fi
	else
		echo "usage:  $FUNCNAME <action> [<chain>] [<option>] [<format>]"
		echo ""
		echo "  <action> = append|check|delete|insert|replace|list|flush|zero|newchain|delchain|dump*"
		echo "  <option> = interface|protocol|source|destination|match|destport|jump"
		echo "  <format> = raw|xml (used for \"dump\" only"
	fi
}

_str_begin_array() {
	NEWAR=()
	SRCH="$(cat -)"
	for EL in $@; do
		if [ -n "$(grep "^$SRCH" <<< "$EL")" ]; then
			NEWAR+=($EL)
		fi
	done
	echo ${NEWAR[@]}
}

_in_array() {
	SRCH="$(cat -)"
	if [ "$1" == "$SRCH" ]; then
		return 0
	else
		shift
		AR="$@"
		if [ -z "$AR" ]; then
			return 1
		else
			_in_array $AR <<< "$SRCH"
		fi
	fi
}

_iptcli_complete() {
	ACTIONS=(append check delete insert replace list flush zero newchain delchain dump)
	OPTIONS=(ifin ifout protocol source destination match destport jump comment)
	[[ -n "${COMP_WORDS[0]}" ]] && CHAINS=($(iptables-save -t ${COMP_WORDS[0]} 2> /dev/null | awk '/^:/ { printf("%s ",gensub(/^:/,"","g",$1)); }'))
	
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${IPT_TABLES[@]} <<< "$LASTCMD"
	if [ $? -eq 0 ]; then
		COMPREPLY=($(_str_begin_array ${ACTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
		return 0
	fi
	
	_in_array ${ACTIONS[@]} <<< "$LASTCMD"
	if [ $? -eq 0 ]; then
		if [ "$LASTCMD" == "list" ]; then
			COMPREPLY=($(_str_begin_array noresolve <<< "${COMP_WORDS[$COMP_CWORD]}"))
			return 0
		elif [ "$LASTCMD" == "dump" ]; then
			COMPREPLY=($(_str_begin_array raw xml <<< "${COMP_WORDS[$COMP_CWORD]}"))
			return 0
		else
			COMPREPLY=($(_str_begin_array ${CHAINS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
			return 0
		fi
	fi
	
	_in_array ${OPTIONS[@]} <<< "$LASTCMD"
	if [ $? -eq 0 ]; then
		return 0
	fi
	
	COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
	return 0
}

_get_ifip4() {
	ifconfig $1 | awk '
		BEGIN { ip="" } 
		/inet[ \t]+/ { 
			ip = gensub(/^.*inet[ \t]+([0-9\.]+)[ \t]+.*$/,"\\1","g",$0);
		} 
		END { printf("%s",ip) }'
}

_get_ifmask4() {
	ifconfig $1 | awk '
		BEGIN { ip="" } 
		/netmask[ \t]+/ {
			mask = gensub(/^.*netmask[ \t]+([0-9\.]+)[ \t]+.*$/,"\\1","g",$0);
		} 
		END { printf("%s",mask) }'
}

_get_ifipv6() {
	ifconfig $1 | awk '
		BEGIN { ip="" } 
		/inet6[ \t]+/ { 
			ip = gensub(/^.*inet6[ \t]+([0-9a-f:]+)[ \t]+.*$/,"\\1","g",$0);
		} 
		END { printf("%s",ip) }'
}

_get_ifprefixv6() {
	ifconfig $1 | awk '
		BEGIN { ip="" } 
		/prefixlen[ \t]+/ {
			mask = gensub(/^.*prefixlen[ \t]+([0-9\.]+)[ \t]+.*$/,"\\1","g",$0);
		} 
		END { printf("%s",mask) }'
}

_if2cidr() {
	IP="$(_get_ifip4 $1)"
	MASK="$(_get_ifmask4 $1)"
	awk -v ip="$IP" '
		function d2b(d, b) {
			while(d) {
				b=d%2b;
				d=int(d/2);
			}
			return(b);
		}
		BEGIN { 
			RS="." ;
			bits=0;
		} {
			binary = d2b($0);
			onebits = gensub(/^(1+)0*$/,"\\1","g",binary);
			bits += length(onebits);
		}
		END {
			printf("%s/%d",ip,bits);
		}' <<< "$MASK"
}



_iface_complete() {
	ACTIONS=(list up down ipv4 ipv6)
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${ACTIONS[@]} <<< "${COMP_WORDS[1]}"
	if [ $? -eq 0 ]; then
		if [ "$LASTCMD" == "list" ]; then
			COMPREPLY=($(_str_begin_array all <<< "${COMP_WORDS[$COMP_CWORD]}"))
			return 0
		else
			_in_array ${ACTIONS[@]} <<< "$LASTCMD"
			if [ $? -eq 0 ]; then
				return 0
			else
				COMPREPLY=($(_str_begin_array ${ACTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))	
				return 0
			fi
		fi
	else
		COMPREPLY=($(_str_begin_array ${ACTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
		return 0
	fi
	
	COMPREPLY=($(_str_begin_array ${ACTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
	return 0
}

iface() {
	if [ -n "$1" ]; then
		IFLIST=($(ifconfig | awk 'BEGIN { FS=":" } /^[^ \t]+:.*$/ { print $1 }'))
		
		if [ "$1" == "list" ]; then
			if [ "$2" == "all" ]; then
				ifconfig
			elif [ -n "$2" ]; then
				_in_array ${IFLIST[@]} <<< "$2"
	
				if [ $? -eq 0 ]; then
					ifconfig $2
				else
					echo "Invalid interface ($2)"
				fi
			else
				for IFACE in ${IFLIST[@]}; do
					echo "$IFACE"
				done
			fi
		elif [ "$1" == "ipv6" ]; then
			if [ -n "$2" ]; then
				_in_array ${IFLIST[@]} <<< "$2"
	
				if [ $? -eq 0 ]; then
					echo "$(_get_ifipv6 $2)/$(_get_ifprefixv6 $2)"
				else
					echo "Invalid interface ($2)"
				fi
			else
				echo "Please specify interface"
			fi
		elif [ "$1" == "ipv4" ]; then
			if [ -n "$2" ]; then
				_in_array ${IFLIST[@]} <<< "$2"
	
				if [ $? -eq 0 ]; then
					echo "$(_if2cidr $2)"
				else
					echo "Invalid interface ($2)"
				fi
			else
				echo "Please specify interface"
			fi
		elif [ "$1" == "up" ]; then
			if [ -n "$2" ]; then
				_in_array ${IFLIST[@]} <<< "$2"
	
				if [ $? -eq 0 ]; then
					ifconfig $2 up
				else
					echo "Invalid interface ($2)"
				fi
			else
				echo "Must specify interface"
			fi
		elif [ "$1" == "down" ]; then
			if [ -n "$2" ]; then
				_in_array ${IFLIST[@]} <<< "$2"
	
				if [ $? -eq 0 ]; then
					ifconfig $2 down
				else
					echo "Invalid interface ($2)"
				fi
			else
				echo "Must specify interface"
			fi
		else
			echo "Invalid command"
		fi
	else
		echo "usage: iface <list | up | down | ipv4 | ipv6> [<interface> | all]"
		echo "      all = only used for list"
	fi
		
}

_connection_complete() {
	OPTIONS=(list test)
	LISTOPT=(tcp tcp6 udp udp6 multicast)
	TESTOPT=(destaddr destport timeout)
		
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${OPTIONS[@]} <<< "${COMP_WORDS[1]}"
	if [ $? -eq 0 ]; then
		if [ "$LASTCMD" == "list" ]; then
			_in_array ${LISTOPT[@]} <<< "$LASTCMD"
			if [ $? -eq 0 ]; then
				return 0
			else
				COMPREPLY=($(_str_begin_array ${LISTOPT[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
				return 0	
			fi
		elif [ "${COMP_WORDS[1]}" == "test" ]; then
			
			_in_array ${TESTOPT[@]} <<< "$LASTCMD"
			if [ $? -eq 0 ]; then
				return 0
			else
				COMPREPLY=($(_str_begin_array ${TESTOPT[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
				return 0
			fi
		else
			return 0
		fi
	else
		COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))		
		return 0
	fi
	
	return 0
}

connection() {
	if [ -n "$1" ]; then
		if [ "$1" == "list" ]; then
			if [ "$2" == "tcp" ]; then
				netstat -ant4 --inet
			elif [ "$2" == "tcp6" ]; then
				netstat -ant6 --inet6
			elif [ "$2" == "udp" ]; then
				netstat -anu --inet
			elif [ "$2" == "udp6" ]; then
				netstat -anu6 --inet6
			elif [ "$2" == "multicast" ]; then
				netstat -ang
			else
				netstat -an --inet --inet6
			fi
		elif [ "$1" == "test" ]; then
			grep 'destaddr' <<< "$@" > /dev/null
			if [ $? -eq 0 ]; then
				DESTADDR="$(sed 's/^.*destaddr[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
				
				CONNTIMEOUT="2"
				
				grep 'timeout' <<< "$@" > /dev/null
				if [ $? -eq 0 ]; then
					CONNTIMEOUT="$(sed 's/^.*timeout[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
				fi
				
				grep 'destport' <<< "$@" > /dev/null
				if [ $? -eq 0 ]; then
					DESTPORT="$(sed 's/^.*destport[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
					
					netcat -zn -w $CONNTIMEOUT $DESTADDR $DESTPORT
					
					if [ $? -eq 0 ]; then
						echo "L4 Connection Successful"
					else
						echo "L4 Connection Failed"
					fi
				else
					ping -W $CONNTIMEOUT -c 1 $DESTADDR > /dev/null
					
					if [ $? -eq 0 ]; then
						echo "L3 Connection Successful"
					else
						echo "L3 Connection Failed"
					fi
				fi
			else
				echo "Must specify address "
			fi
		else
			echo "Must specify options"
		fi
	else
		echo "usage: connection [list | test] [<list-opts> | <test-opts>]"
		echo "      list-opts = tcp tcp6 udp udp6 multicast"
		echo "      test-opts = destaddr destport timeout"	
	fi
}

_traffic_complete() {
	OPTIONS=(capture stats)
	OTHEROPTS=(file interface list)
		
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${OPTIONS[@]} <<< "${COMP_WORDS[1]}"
	if [ $? -eq 0 ]; then
		_in_array ${OTHEROPTS[@]} <<< "$LASTCMD"
		if [ $? -eq 0 ]; then
			
			return 0
		else
			COMPREPLY=($(_str_begin_array ${OTHEROPTS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
			return 0	
		fi

	else
		COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))		
		return 0
	fi
	
	return 0
}

traffic() {
	if [ -n "$1" ]; then
		if [ "$1" == "capture" ]; then
			if [ "$2" == "list" ]; then
				CAPFILES="$(ls /tmp/*pcap 2>/dev/null)"
				
				if [ $? -eq 0 ]; then
					echo "$CAPFILES"
				else
					echo "No capture files found"
				fi
			else
				grep 'interface' <<< "$@" > /dev/null && grep 'file' <<< "$@" > /dev/null
				
				if [  $? -eq 0 ]; then
					IFNAME="$(sed 's/^.*interface[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
					OUTFILE="$(sed 's/^.*file[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
					
					tcpdump -i $IFNAME -s 65535 -w /tmp/$OUTFILE.pcap
					
					chmod 777 /tmp.$OUTFILE.pcap
					
					echo "Capture saved to /tmp/$OUTFILE.pcap"
				else
					echo "Must specify interface and output file"
				fi
			fi
		elif [ "$1" == "stats" ]; then
			grep 'interface' <<< "$@" > /dev/null
			
			if [  $? -eq 0 ]; then
				IFNAME="$(sed 's/^.*interface[ \t]\+\([^ \t]\+\)[ \t]*.*$/\1/g' <<< "$@")"
			
				ifconfig $IFNAME | awk '/[RT]X/ { print gensub(/^[ \t]+(.*)$/,"\\1","g",$0); }'
			else
				echo "Must specify interface"
			fi
		else
			echo "Invalid option ($1)"
		fi
	else
		echo "usage: traffic [stats | capture] [list] interface <ifname> [file <filename>]"
		echo "      file = only used for capture"
		echo "      list = only used for capture"
	fi
}

_traceroute_complete() {
	OPTIONS=(hops addr)
	
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${OPTIONS[@]} <<< "$LASTCMD"
	if [ $? -eq 0 ]; then
		return 0
	else
		COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
		return 0
	fi
}

_lookup_complete() {
	OPTIONS=(host type)
	
	LASTCMD="${COMP_WORDS[$COMP_CWORD-1]}"
	
	_in_array ${OPTIONS[@]} <<< "$LASTCMD"
	if [ $? -eq 0 ]; then
		return 0
	else
		COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
		return 0
	fi
}

lookup() {
	ARGS="$@"
	HOST="$(sed 's/^.*host[ \t]\+\([^ \t]\+\).*$/\1/g' <<< "$ARGS")"
	TYPE="$(sed 's/^.*type[ \t]\+\([^ \t]\+\).*$/\1/g' <<< "$ARGS")"
	
	if [ "$ARGS" == "$HOST" ] || [ "$ARGS" == "$TYPE" ]; then
		echo "usage: lookup host <hostname> type <record-type>"
	else
		dig $HOST $TYPE | grep -v '^;\|^[ \t]*$'
	fi
}

trace() {
	ARGS="$@"
	HOPS="$(sed 's/^.*hops[ \t]\+\([^ \t]\+\).*$/\1/g' <<< "$ARGS")"
	HOST="$(sed 's/^.*addr[ \t]\+\([^ \t]\+\).*$/\1/g' <<< "$ARGS")"
	
	if [ "$ARGS" == "$HOST" ]; then
		echo "usage: trace hops <hop-count> host <hostname/IP>"
	else
		traceroute -n $([[ "$ARGS" == "$HOPS" ]] || echo "-m $HOPS") $HOST | grep '^[ \t]\+[0-9]'
	fi
}

_clidebug_complete() {
	OPTIONS=(on off)
	
	_in_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD-1]}"
	if [ $? -eq 0 ]; then
		return 0
	else
		COMPREPLY=($(_str_begin_array ${OPTIONS[@]} <<< "${COMP_WORDS[$COMP_CWORD]}"))
		return 0	
	fi
	
}

clidebug() {
	if [ "$1" == "on" ]; then
		set -x
	elif [ "$1" == "off" ]; then
		set +x
	else
		echo "usage: clidebug <on | off>"
	fi
}

contains() {
	if [ -n "$1" ]; then
		grep "$@"
	else
		echo "usage: contains <expression>"
	fi
}

count() {
	if [ -n "$1" ]; then
		grep "$@" | wc -l
	else
		echo "usage: count <expression>"
	fi
}

column() {
	if [ -n "$1" ]; then
		awk '{ print $'"$1"' }'
	else
		echo "usage: column <number>"
	fi
}

admin() {
	/usr/bin/bash
}

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

calc() {
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
				return 1
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
}

for THISTAB in ${IPT_TABLES[@]}; do
	eval "$THISTAB() { _iptcli_backend \$FUNCNAME \$@; }"
	complete -F _iptcli_complete $THISTAB
done

complete -F _iface_complete iface
complete -F _connection_complete connection
complete -F _traffic_complete traffic
complete -F _traceroute_complete trace
complete -F _lookup_complete lookup
complete -F _clidebug_complete clidebug
complete -W "" contains
complete -W "" count
complete -W "" ping
complete -W "" column