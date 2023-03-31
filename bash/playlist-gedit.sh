#!/bin/bash

FOLDER=$(zenity --file-selection --directory --title="Select folder containing MP3's")
FILENAME="/tmp/$(basename $FOLDER)-$(date +'%Y%m%d-%H%M%S').pls"

ls $FOLDER/*mp3 | awk 'BEGIN { printf("[playlist]\nNumberOfEntries="); system("ls '"$FOLDER"'/*mp3| wc -l") } { printf("File%d=%s\n", NR, $0) }' > $FILENAME

gedit $FILENAME