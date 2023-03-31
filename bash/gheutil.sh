#!/bin/bash

########################################
# gheutil.sh
#
# Display newest available version of Github Enterprise or download newest package
#
# usage:
#    gheutil.sh -i
#      Display newest version availablility
#    gheutil.sh -d
#      Download newest installer package
########################################

if [ -z "$1" ]; then
        echo "usage: gheutil.sh <-i | -d>"
else
        if [ "$1" == "-i" ]; then
                RELINFO="$(curl -s https://enterprise.github.com/releases | grep -A3 '<div class="release"' | head -n4)"
                RELDAY="$(echo "$RELINFO" | grep 'release-date' | sed 's/^.*note\">//g;s/<.*$//g')"
                DAYAGE="$(echo "($(date +%s)-$(date -d "$RELDAY" +%s))/86400" | bc)"
                RELVERSION="$(echo "$RELINFO" | head -n1 | sed 's/^.*release-//g;s/\".*$//g')"
                echo "Github Enterprise version $RELVERSION has been available for $DAYAGE days."
        elif [ "$1" == "-d" ]; then
                RELINFO="$(curl -s https://enterprise.github.com/releases | grep -A3 '<div class="release"' | head -n4)"
                RELVERSION="$(echo "$RELINFO" | head -n1 | sed 's/^.*release-//g;s/\".*$//g')"
                curl https://github-enterprise.s3.amazonaws.com/esx/updates/github-enterprise-esx-$RELVERSION.pkg > github-enterprise-esx-$RELVERSION.pkg
        else
                echo "Invalid argument ($1)"
        fi
fi