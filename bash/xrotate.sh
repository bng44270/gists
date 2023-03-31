#!/bin/bash

######################
# Installation:
#   1) Create the following symbolic links to xrotate.sh
#       - xrotate-right.sh
#       - xrotate-left.sh
#
#   2) Modify the value of XDISP below to reflect the XWindows output device
#
#   3) Assign keyboard shortcuts to execute the specific shell scripts to
#      display informational notifications
######################

XDISP="eDP-1"

rotatescreen() {
	CUROR="$(xrandr | grep "$XDISP")"
	
	if [ -n "$(grep "right (" <<< "$CUROR")" ]; then
		[[ "$1" == "right" ]] && xrandr --output $XDISP --rotate inverted
		[[ "$1" == "left" ]] && xrandr --output $XDISP --rotate normal
	elif [ -n "$(grep "left (" <<< "$CUROR")" ]; then
		[[ "$1" == "right" ]] && xrandr --output $XDISP --rotate normal
		[[ "$1" == "left" ]] && xrandr --output $XDISP --rotate inverted
	elif [ -n "$(grep "inverted (" <<< "$CUROR")" ]; then
		[[ "$1" == "right" ]] && xrandr --output $XDISP --rotate left
		[[ "$1" == "left" ]] && xrandr --output $XDISP --rotate right
	else
		[[ "$1" == "right" ]] && xrandr --output $XDISP --rotate right
		[[ "$1" == "left" ]] && xrandr --output $XDISP --rotate left
	fi
}

rotatescreen $(basename $0 | sed 's/xrotate-\([^\.]\+\)\.sh/\1/g')