#!/bin/bash

#########################################
# get-gist.sh <github-username> < -l | -f gist-filename >
#
# Two functions:  list gists or download gist
#
# List Gists:
#
#     returns a tab-delimited list of gists and filenames
#
#     Example command:
#
#            get-gist.sh list bng44270
#
#     Example output:
#
#            https://gist.github.com/bng44270/1084f2b0809930098fb8	bigip-redirect-irule.sh
#            https://gist.github.com/bng44270/3d5ecb2990f81762c70f	zabbix-agent-install.bat
#
# Download Gist:
#
#     Download the content of a gist to a file of the same name
#
#     Example command:
#
#            get-gist.sh download bng44270 get-gist.sh    
#
# Clone Gist:
#
#     Clone the gist to a local folder
#
#     Example command:
#
#            get-gist.sh clone bng44270 get-gist.sh
#
# Other Commands:
#
#     get-gist.sh download-all bng44270
#
#     get-gist.sh clone-all bng44270
#
#########################################

usage() {
	echo "usage:"
        echo "       get-gist.sh list <github-username>"
        echo "       get-gist.sh download <github-username> <gist-filename>"
        echo "       get-gist.sh download-all <github-username>"
        echo "       get-gist.sh clone <github-username> <gist-filename>"
        echo "       get-gist.sh clone-all <github-username>"
}

if [ -z "$1" ]; then
	usage
else
	if [ "$1" == "clone" ]; then
		$0 list $2 | awk '{ print $1 }' | sed 's/$/.git/g' | grep "$2" | xargs git clone
	elif [ "$1" == "clone-all" ]; then
		$0 list $2 | awk '{ print $1 }' | sed 's/$/.git/g' | while read line; do
			git clone $line
		done
	elif [ "$1" == "list" ]; then
		gisturl="https://gist.github.com/$2"
		while [ -n "$gisturl" ]; do
			curl -s "$gisturl" | grep css-truncate-target | grep -v ">$2<" | sed 's/^.*href="//g;s/".*css-truncate-target">/\t/g;s/<.*$//g;s/^/https:\/\/gist.github.com/g'
			export gisturl=$(curl -s "$gisturl" | grep '>Newer<.*href.*>Older<' | sed 's/^.*href="//g;s/".*$//g')
		done
	elif [ "$1" == "download" ]; then
		thisgisturl=""
		gisturl="https://gist.github.com/$2"

		while [ -n "$gisturl" ]; do
			export thisgisturl=$(curl -s "$gisturl" | grep css-truncate-target | grep ">$3<" | sed 's/^.*href="//g;s/".*$//g;s/^/https:\/\/gist.github.com/g')
			export gisturl=$(curl -s "$gisturl" | grep '>Newer<.*href.*>Older<' | sed 's/^.*href="//g;s/".*$//g')
			if [ -n "$thisgisturl" ]; then
				break
			fi
		done

		if [ -n "$thisgisturl" ]; then
			thisgisturlraw=$(curl -s "$thisgisturl" | grep '>Raw<' | sed 's/^.*href="//g;s/".*$//g;s/^/https:\/\/gist.githubusercontent.com/g')
			curl $thisgisturlraw > ./$3
		else
			echo "File $3 not found"
		fi
	elif [ "$1" == "download-all" ]; then
		$0 list $2 | awk '{ print $2 }' | while read line; do
			$0 download $2 $line
		done
	else
		echo "Invalid option -- $@"
		usage
	fi
fi