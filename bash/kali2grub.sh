#!/bin/bash

# Configure Grub to boot from Kali ISO
#
# Step 1:
#   1.  Run `./kali2grub.sh -f /path/to/kali.iso`
#   2.  Take note of path to temp file from step #1
#   3.  Run ` ./kali2grub.sh -u /path/to/tempfile`  (NOTE:  Requires sudo access)
#   4.  Reboot your system
#
#  Tested on Debian 9

if [  -z "$1" ]; then
  echo "usage: kali2grub.sh <-f ISO_IMG | -u TEMP_FILE>"
  echo "   -f => parse ISO_IMG and return a temp file"
  echo "         to use to reconfigure Grub"
  echo "   -u => use TEMP_FILE to configure Grub and"
  echo "         copy ISO image to /boot/iso"
else
  if [ "$1" == "-f" ] && [ -f $2 ]; then
    ISOBASE="$(basename $2)"
    DIR="/tmp/iso-$RANDOM"
    CONFIG="$DIR-grub.cfg"
    
    mkdir $DIR
    echo "$2" > $CONFIG
    sudo mount $2 $DIR
    sed 's/^\([ \t]\+\)\(linux[0-9]*[ \t]\+\)\(.*\)$/\1loopback loop \/boot\/iso\/'"$ISOBASE"'\n\1\2\(loop\)\3 findiso=\/boot\/iso\/'"$ISOBASE"'/g;s/^\([ \t]\+initrd[ \t]\+\)\(.*\)$/\1\(loop\)\2/g' $DIR/boot/grub/grub.cfg | \
      awk 'BEGIN { printf("#BEGIN Kali Linux\nsubmenu \"Kali Linux\" {"); showline = 0 } /^menuentry/ { showline = 1 } /^}/ { print; showline = 0; } { if (showline == 1) print } END { printf("\n#END Kali Linux"); }' >> $CONFIG
    sudo umount $DIR
    
    rmdir $DIR
    
    echo "Config temp file:  $CONFIG"
  elif [ "$1" == "-u" ] && [ -f $2 ]; then
    [[ ! -d /boot/iso ]] && sudo mkdir /boot/iso
    ISOFILE="$(head -n1 $2)"
    sudo cp $ISOFILE /boot/iso
    sudo tail -n +2 $2 | sudo tee -a /etc/grub.d/40_custom > /dev/null
    sudo update-grub
  else
    echo "Invalid options ($@)"
  fi
fi