#!/bin/bash

###################################
#
# Radio Player (GUI)
#
# Requires zenity
#
# Usage:
#
#    1) Create M3U playlist file using the following syntax:
#
#          #EXTINF:0,<Radio Station Name>
#          <Radio Station URL>
#
#    2) Repease step 1 for each radio station
#
#    3) Update the PLAYLIST variable below with the full
#       path to the M3U playlist you created
#
###################################

PLAYLIST="/path/to/playlist.m3u"

while true; do
	STATION="$(awk 'BEGIN { FS="," } /^#EXTINF/ { print $2 }' < $PLAYLIST | zenity --list --column="Station" --title="Radio Player" --width=300 --height=530)"
	
	if [ $? -eq 1 ]; then
		break
	fi
	
	URL="$(grep -A1 $STATION $PLAYLIST | tail -n1)"
	
	ffplay -loglevel 8 -nodisp "$URL" &
	
	zenity --info --text="Playing\n$STATION" --width=300 --ok-label="Stop" --title="Radio Player"
	
	FFPLAY_PID="$(ps -ef | grep "[f]fplay.*$URL" | awk '{ print $2 }')"
	
	kill -9 $FFPLAY_PID
done