#!/bin/bash

##################################
#
# Launch nested X windows session
#
# Usage:
#
#    1) Determine window manager executable (i.e. wmaker)
#
#    2) Create symbolic link of xnest.sh
#
#           $ ln -s xnest.sh xnest-wmaker.sh
#
#    3) Update the GEOMETRY and DISPLAY_VALUE variables to
#       reflect the desired X windows resolution and display 
#       name respectively
#
##################################

GEOMETRY="1024x768+64+0"
DISPLAY_VALUE=":1"

###############################
# Edit nothing below here
###############################

WMGR="$(basename $0 | sed 's/^xnest[-]*//g;s/\.sh$//g')"

if [ -z "$WMGR" ]; then
	echo "usage:  xnest-<window_manager>.sh"
	echo "      ln -s xnest.sh xnest-<window_manager>.sh"
else
	Xnest -geometry $GEOMETRY $DISPLAY_VALUE -ac &
	NESTPID="$(jobs -l | awk '/Xnest/ { print $2 }')"
	DISPLAY="$DISPLAY_VALUE" $WMGR
	kill -9 $NESTPID
fi