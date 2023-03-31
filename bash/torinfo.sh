#!/bin/bash

#######################
# torinfo.sh
#
# Get Tor node information 
# by IP address from dan.me.uk
#
#######################

getargs() {
	echo "$@" | sed 's/[ \t]\+\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }'
}

eval "$(getargs "$@")"

if [ -z "$ARG_i" ]; then
	echo "usage: torinfo.sh -i <ip-address>"
else
		PTR="$(sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)/\4\.\3\.\2\.\1\.tor.dan.me.uk/g' <<< "$ARG_i")"
		dig $PTR TXT | \
		awk -v oip="$ARG_i" 'BEGIN {
			found = 0;
			dnsflag["E"] = "Exit";
			dnsflag["X"] = "Hidden";
			dnsflag["A"] = "Authority";
			dnsflag["B"] = "BadExit";
			dnsflag["C"] = "NoEdConsensus";
			dnsflag["D"] = "V2Dir";
			dnsflag["F"] = "Fast";
			dnsflag["G"] = "Guard";
			dnsflag["H"] = "HSDir";
			dnsflag["N"] = "Named";
			dnsflag["R"] = "Running";
			dnsflag["S"] = "Stable";
			dnsflag["U"] = "Unnamed";
			dnsflag["V"] = "Valid";
		} 
		/^[^;].*[ \t]+TXT[ \t]+/ { 
			found = 1;
			info = gensub(/^.*[ \t]+TXT[ \t]+"([^"]+)".*$/,"\\1","g",$0);
			infoarlen = split(info,infoar,"/");
			idx = 0;
			printf("%12s: %s\n","IP Address",oip);
			while (idx <= infoarlen) {
				if (match(/^[ \t]*$/,infoar[idx])) idx++;
				param = gensub(/^([^:]+):.*$/,"\\1","g",infoar[idx]);
				pval = gensub(/^[^:]+:(.*)$/,"\\1","g",infoar[idx]);
				if (param == "N") printf("%12s: %s\n","Node Name",pval);
				if (param == "P") printf("%12s: %s\n","Ports",pval);
				if (param == "F") {
					printf("%12s: ","Flags");
					flagarlen = split(pval,flagar,"");
					fidx = 0;
					while (fidx <= flagarlen) {
						if (match(/^[ \t]*$/,flagar[fidx])) fidx++;
						printf("%s ",dnsflag[flagar[fidx]]);
						fidx++;
					}
				}
				idx++;
			}
		}
		END {
			if (found == 0) {
				printf("TOR node not found (%s)",oip);
			}
		}'
fi
