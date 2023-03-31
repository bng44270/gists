#!/bin/bash

##########################################################
# custom.sh - Create a collection of custom Bash functions
#
# Usage:
#   1. Run 'custom.sh' and provide the new script name when prompted
#   2. Add Bash functions to the top of the new script file above
#      the comment block.
#   3. Run the script file and as long as you have permission a symbolic
#      link will be created in the same file path for the purpose of invoking
#      the newly created Bash function.
#
# As functions are added to the script file the original script file created
# in step 1 will need to be re-run.
##########################################################


read -p "Enter new script name: " binname
echo '#!/bin/bash' > $(dirname $0)/$binname
echo '' >> $(dirname $0)/$binname
m4 -DBINNAME="$binname" $0 | tail -n34 >> $(dirname $0)/$binname
chmod +x $(dirname $0)/$binname
echo "You may now use '$binname' to develop and execute custom Bash functions"
echo "that can be executed via the command line."
exit 0

##################################
# EDIT NOTHING BELOW HERE
##################################

BASEBIN="BINNAME"
BINPRE="$(sed 's/^\([^\.]\+\).*$/\1/g' <<< "$BASEBIN")"
BINEXT="$(sed 's/^[^\.]\+\(.*\)$/\1/g;s/\./\\\./g' <<< "$BASEBIN")"

list="$(awk '/^[a-z0-9]+\(\)/ { print gensub(/[\(\)]/,"","g",$1); }' $0)"

if [ -w $(dirname $0)/ ] && [ "$(basename $0)" == "$BASEBIN" ]; then
  echo -n "Building alias'..."
  for bin in "$list"; do
    if [ -z "$bin" ]; then
    	continue
    fi
    NEWNAME="$(sed 's/^\([^\.]\+\)\(\.sh\)$/\1-'"$bin"'\2/g' <<< "$BASEBIN")"
    ln -s $(dirname $0)/$(basename $0) $(dirname $0)/$NEWNAME
  done
  echo "done"
fi

action="$(basename $0 | sed 's/^'"$BINPRE"'[-]*//g;s/'"$BINEXT"'$//g')"

if [ -z "$action" ]; then
	if [ -z "$list" ]; then
		echo "No functions available"
	else
		echo "Available commands:"
		sed 's/^/  '"$BINPRE"'-/g;s/$/'"$BINEXT"'/g' <<< "$list"
	fi
else
	$action
fi