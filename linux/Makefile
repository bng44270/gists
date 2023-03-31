#################
# newsetting
#
# Writes a name/value pair to a defined text file.  This function pairs with the getsetting function.
#
# Syntax:
#   $(call newsetting,PROMPT-TEXT,SETTING-NAME,DEFAULT-VALUE,SETTING-FILE)
#
# Example:
#   $(call newsetting,Enter the binary path,BINPATH,/usr/local/bin,/tmp/settings)
#
# This will create the following user prompt:
#   Enter the binary path [/usr/local/bin]:
#
# The resulting file (/tmp/settings) if left with the default settings will look like this:
#   BINPATH /usr/local/bin
#################
define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" | sed 's/\/$$//g' >> $(4)
endef

#################
# getsetting
#
# Reads a value from a file based on the name.  This fucntion pairs with the newsetting function.
#
# Syntax:
#   $(call getsetting,SETTING-NAME,SETTING-FILE)
#
# Example:
#   $(call newsetting,BINPATH,/tmp/settings)
#################
define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

#################
# newlist
#
# Defines a list and writes list to a specified file
#
# Syntax:
#   $(call newlist,/tmp/people)
#################
define newlist
@echo "Enter a blank line when finished"
@while true; do read -p "$(1): " thisval ; [[ -z "$$thisval" ]] && break ; echo "$$thisval" >> $(2) ; done
endef

#################
# m4define
#
# Defines an  m4 macro
#
# Syntax (single-line):
#   $(call m4define,TMPFOLDER,/tmp)" > test.m4
#
# Syntax (multi-line):
#   $(call m4define,FILEDATA,Line 1\nLine2\nLine 3)
#################
define m4define
@echo -e "define(\`$(1)',\`$(shell printf "$(2)" | sed -z 's/\n/\\n/g')')"
endef