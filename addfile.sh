#!/bin/bash

_build_file_types() {
	ls -d $@/* | while read folder; do
		if [ "$folder" == "." ] || [ "$folder" == ".." ]; then
			continue
		fi
		
		if [ -d $folder ]; then
			ls $folder | while read file; do
				sed 's/^.*\.\([^.]\+\)$/\1/g' <<< "$file"
			done | sort | uniq | while read ext; do
				echo "$(basename $folder)|$ext"
			done
		fi
	done
}

if [ -z "$1" ] || [ ! -f $1 ]; then
	echo "usage:  addfile.sh <file>"
else
	BASEDIR="$(dirname $0)"
	NEWFILE="$1"
	NEWTYPE="$(sed 's/^.*\.\([^.]\+\)$/\1/g' <<< "$NEWFILE")"
	DESTFOLDER="$(_build_file_types $BASEDIR | awk -v type="$NEWTYPE" 'BEGIN { FS="|" } { if (type == $2) { print $1 } }')"
	cp -v $NEWFILE $BASEDIR/$DESTFOLDER
fi
