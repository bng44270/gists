#!/bin/sh

######################################################
#
# dropbox-for-gedit
#
#    Requirements:
#        zenity
#        dropbox_uploader.sh (configured with an account)
#            Download from https://github.com/andreafabrizi/Dropbox-Uploader
#
#    Installation:
#        1. Modify DUFOLDER variable below to specify where dropbox_uploader.sh lives
#        2. Modify EDITOR to have the executable name of editor application (gedit or pluma)
#        2. Copy and paste this script into a new gedit external tool (Tools -> Manage External Tools)
#
######################################################

EDITOR="gedit"

DUFOLDER="/home/ace/Documents/Git-Repos/Dropbox-Uploader"

alias dropbox="$DUFOLDER/dropbox_uploader.sh"

DBACTION=$(printf "Make Directory\nEdit File\nSave File" | zenity --list --column="Action" --title="Dropbox for GEdit" --text="")

if [ -n "$(echo $DBACTION | grep 'Make Directory')" ]; then
        dropbox mkdir /$(zenity --entry --title="Mkdir" --text="")
elif [ -n "$(echo $DBACTION | grep 'Save File')" ]; then
        TARGETPATH=$(dropbox list | grep '\[D\]' | sed 's/^ \[D\][ \t]*//g' | zenity --list --column="Folder" --title="Select Folder" --text="")
        dropbox upload $GEDIT_CURRENT_DOCUMENT_DIR/$GEDIT_CURRENT_DOCUMENT_NAME $TARGETPATH
elif [ -n "$(echo $DBACTION | grep 'Edit File')" ]; then
	REMOTEPATH=$(dropbox list | grep '\[D\]' | sed 's/^ \[D\][ \t]*//g' | zenity --list --column="Folder" --title="Select Folder" --text="")
	REMOTEFILE=$(dropbox list $REMOTEPATH | grep '\[F\]' | sed 's/^ \[F\][ \t]*[0-9]*[ \t]*//g' | zenity --list --column="File" --title="Select File" --text="")
	dropbox download $REMOTEPATH/$REMOTEFILE /tmp/$REMOTEFILE
	$EDITOR /tmp/$REMOTEFILE
else
        zenity --error --title="Error" --text="Invalid action"
fi