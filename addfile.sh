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
	echo -n "Placing file in folder structure..."
	BASEDIR="$(dirname $0)"
	NEWFILE="$1"
	NEWTYPE="$(sed 's/^.*\.\([^.]\+\)$/\1/g' <<< "$NEWFILE")"
	DESTFOLDER="$(_build_file_types $BASEDIR | awk -v type="$NEWTYPE" 'BEGIN { FS="|" } { if (type == $2) { print $1 } }')"
	if [ -z "$DESTFOLDER" ]; then
		echo "Unknown extension ($NEWTYPE)"
		exit 1
	else
		cp $NEWFILE $BASEDIR/$DESTFOLDER
		echo "done ($DESTFOLDER/$(basename $NEWFILE))"		
	fi
	
	echo -n "Rebuilding README.md..."
	
	echo "# Repository of Gists  " > $BASEDIR/README.md
	echo "<https://gist.github.com/bng44270>  " >> $BASEDIR/README.md
	
	find $BASEDIR -type d | grep -v '.git\|^.$' | while read line; do
		FOLDER="$(basename $line)"
		echo "- $FOLDER  "
		ls $line/ | while read file; do
			FILENAME="$(basename $file)"
			URL="https://github.com/bng44270/gists/blob/main/$FOLDER/$FILENAME"
			echo "  - [$FILENAME]($URL)  "
		done
	done >> $BASEDIR/README.md
	
	echo "done"
fi
