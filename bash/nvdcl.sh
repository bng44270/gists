#!/bin/bash

feedval() {
	[[ -n "$(grep "[0-9]\{4\}" <<< "$1")" || "$1" == "recent" || "$1" == "modified" ]] && return 0 || return 1
}

getargs() {
	[[ -z "$1" ]] && echo "usage: getargs <arguments>" || echo "$@" | sed 's/\(-[a-zA-Z] \)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/\n/,"","g",gensub(/^-/,"","g",$1)),length($2)==0?"EMPTY":gensub(/\n/,"","g",$2)) }'
}

xmlpretty() {
	sed 's/\(<\/[^>]\+>\)/\1\n/g;s/\(>\)\(<\)/\1\n\2/g'
}

usage() {
	echo "usage: nvdcl.sh -f <feed> [-c <zip|gz> -t <xml|json>] [-o <output-file>]"
	echo "     feed => <year>, modified, or recent"
	echo "     -c and -t are dependant on each other"
}

[[ -n "$@" ]] && eval $(getargs $@)

if [ -z "$ARG_f" ]; then
	usage
else
	feedval $ARG_f
	if [ $? -eq 0 ]; then
		if [ -z "$ARG_c" ] && [ -z "$ARG_t" ] && [ -z "$ARG_o" ]; then
			curl -ks https://nvd.nist.gov/vuln/data-feeds | tr -d '\r' | tr -d '\n' | \
			sed 's/\(<tr\)/\n\1/g;s/\(<\/tr>\)/\1\n/g;s/>[ \t]*</></g' | grep '^<tr.*vuln-xml-feed' | xmlpretty | \
			awk '/^<a href=.*\/xml\/cve\/2.0\/.*'$ARG_f'.*gz/ { 
				printf("%-15s%s\n","GZipFileUrl",gensub(/^<a href='"'"'(.*gz)'"'"'.*$/,"\\1","g",$0)) 
			} 
			/^<a href=.*\/xml\/cve\/2.0\/.*'$ARG_f'.*zip/ { 
				printf("%-15s%s\n","ZipFileUrl",gensub(/^<a href='"'"'(.*zip)'"'"'.*$/,"\\1","g",$0))
			} 
			/^<a href=.*\/xml\/cve\/2.0\/.*'$ARG_f'.*meta/ { 
				printf("%-15s%s\n","MetadataUrl",gensub(/^<a href='"'"'(.*meta)'"'"'.*$/,"\\1","g",$0)) 
			}'
		else
			if [ "$ARG_t" == "json" ]; then
				if [ "$ARG_c" == "gz" ] || [ "$ARG_c" == "zip" ]; then
					OUTFILE="$([[ -z "$ARG_o" ]] && echo "/tmp/${ARG_f}-${ARG_t}-$(date +"%m%d%Y").${ARG_c}" || echo $ARG_o)"
					echo -n "Downloading $OUTFILE ..."
					curl -sk https://nvd.nist.gov/vuln/data-feeds | tr -d '\r' | tr -d '\n' | \
					sed 's/\(<tr\)/\n\1/g;s/\(<\/tr>\)/\1\n/g;s/>[ \t]*</></g' | grep '^<tr.*vuln-json-feed' | xmlpretty | \
					awk '/^<a href=.*\/json\/cve\/.*'$ARG_f'.*'$ARG_c'/ { printf("%s",gensub(/^<a href='"'"'(.*'$ARG_c')'"'"'.*$/,"\\1","g",$0)) }' | \
					curl -sk $(cat -) > $OUTFILE
					echo "done"
				else 
					echo "Invalid compression type ($ARG_c)"
					usage
				fi
			elif [ "$ARG_t" == "xml" ]; then
				if [ "$ARG_c" == "gz" ] || [ "$ARG_c" == "zip" ]; then
					OUTFILE="$([[ -z "$ARG_o" ]] && echo "/tmp/${ARG_f}-${ARG_t}-$(date +"%m%d%Y").${ARG_c}" || echo $ARG_o)"
					echo -n "Downloading $OUTFILE ..."
					curl -ks https://nvd.nist.gov/vuln/data-feeds | tr -d '\r' | tr -d '\n' | \
					sed 's/\(<tr\)/\n\1/g;s/\(<\/tr>\)/\1\n/g;s/>[ \t]*</></g' | grep '^<tr.*vuln-xml-feed' | xmlpretty | \
					awk '/^<a href=.*\/xml\/cve\/2.0\/.*'$ARG_f'.*'$ARG_c'/ { printf("%s",gensub(/^<a href='"'"'(.*'$ARG_c')'"'"'.*$/,"\\1","g",$0)) }' | \
					curl -sk $(cat -) > $OUTFILE
					echo "done"
				else 
					echo "Invalid compression type ($ARG_c)"
					usage
				fi
			else
				echo "Invalid type ($ARG_t)"
				usage
			fi
		fi
	else
		echo "Invalid feed ($ARG_f)"
		usage
	fi
fi