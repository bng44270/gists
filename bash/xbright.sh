#!/bin/bash

######################
# Installation:
#   1) Create the following symbolic links to xbright.sh
#       - xbright-up.sh
#       - xbright-down.sh
#
#   2) Modify the value of XDISP below to reflect the XWindows output device
#
#   3) Assign keyboard shortcuts to execute the specific shell scripts to
#      display informational notifications
######################

XDISP="eDP-1"

getxbright() {
	xrandr --verbose | awk '/^[ \t]+Brightness/ { print $2 }'
}

xbright() {
	if [ "$1" == "up" ]; then
		xrandr --output $XDISP --brightness $([[ "$(getxbright)" == "1.0" ]] && echo "1.0" || echo "$(bc <<< "$(getxbright) + 0.1" | sed 's/^\./0\./g')")
	fi

	if [ "$1" == "down" ]; then
		xrandr --output $XDISP --brightness $([[ "$(getxbright)" == "0.1" ]] && echo "0.1" || echo "$(bc <<< "$(getxbright) - 0.1" | sed 's/^\./0\./g')")
	fi

	notify-send "Brightness" "$(bc <<< "$(getxbright)*100" | sed 's/\.0\+//g')%"
}

xbright $(basename $0 | sed 's/xbright-\([^\.]\+\)\.sh$/\1/g')