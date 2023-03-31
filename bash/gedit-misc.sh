# line, Word, and character count for gedit, respectively
zenity --info --title="Word Count" --text="$(wc -w)"
zenity --info --title="Character Count" --text="$(wc -c)"
zenity --info --title="Line Count" --text="$(wc -l)"

# Does a regex substitute on the current file with sed (saves backup file)
sed -i.$(ls $GEDIT_CURRENT_DOCUMENT_DIR/$GEDIT_CURRENT_DOCUMENT_NAME | wc -l) 's/'"$(zenity --entry --title "" --text="Enter search pattern")"'/'"$(zenity --entry --title "" --text="Enter replace pattern")"'/g' $GEDIT_CURRENT_DOCUMENT_DIR/$GEDIT_CURRENT_DOCUMENT_NAME