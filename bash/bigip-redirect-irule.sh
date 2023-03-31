#!/bin/bash

####################
#
# Usage: bigip-redirect-irule.sh <text file> <tcl filename>
#
# The format of the text file will be:
#
#       UrlPath<TAB>DestinationURL<NEWLINE>
#
# So when /UrlPath is accessed the user will be redirected to DestinationURL 
#
# NOTE:  Added support for query strings by using HTTP::path and HTTP::query as opposed to HTTP::uri in regsub
#
# The iRule is saved to the <tcl filename> argument provided.  The iRule uses an associative array indexed by
# the UrlPath where the corresponding value is the DestinationURL
#
# NOTE:  If you want UrlPath to be appended to the end of DestinationURL add BIGIPREDIRURL to the end of DestinationURL
#
# iRule sample output (redirURLs populated with sample data):
# 
# when HTTP_REQUEST {
# 	set redirURLs("/one") "http://www.google.com"
# 	set redirURLs("/two") "http://github.com"
# 
# 	foreach {name value} [array get redirURLs] {
# 		if { [string tolower [HTTP::uri]] starts_with [string tolower [string trim $name "\""]] } {
# 			if { $value contains "BIGIPREDIRURL" } {
#         if { [string length [HTTP::query]] } {
# 				  HTTP::redirect [regsub "BIGIPREDIRURL" $value [HTTP::path]]?[HTTP::query]
#         }
#         else {
#           HTTP::redirect [regsub "BIGIPREDIRURL" $value [HTTP::path]]
#         }
# 			}
# 			else {
# 				HTTP::redirect $value
# 			}
# 			break
# 		}
# 	}
# }
####################

if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "usage: create-redir.sh <redirect-filename> <tcl-filename>"
else
  redirfile="$1"
  tclfile="$2"
  printf "when HTTP_REQUEST {\n" > $tclfile

  cat $redirfile | while read line; do 
  	thispath=$(echo "$line" | awk 'BEGIN { FS="\t" } { print $1 }' )
  	thisurl=$(echo "$line" | awk 'BEGIN { FS="\t" } { print $2 }' )
  	printf "\tset redirURLs(\"$thispath\") \"$thisurl\"\n" >> $tclfile
  done
  
  printf "\n\tforeach {name value} [array get redirURLs] {\n" >> $tclfile
  printf "\t\tif { [string tolower [HTTP::uri]] starts_with [string tolower [string trim \$name \"\\\\\"\"]] } {\n" >> $tclfile
  printf "\t\t\tif { \$value contains \"BIGIPREDIRURL\" } {\n" >> $tclfile
  printf "\t\t\t\tif { [string length [HTTP::query]] } {\n" >> $tclfile
  printf "\t\t\t\t\tHTTP::redirect [regsub \"BIGIPREDIRURL\" \$value [HTTP::path]]\?[HTTP::query]\n" >> $tclfile
  printf "\t\t\t\t}\n" >> $tclfile
  printf "\t\t\t\telse {\n" >> $tclfile
  printf "\t\t\t\t\tHTTP::redirect [regsub \"BIGIPREDIRURL\" \$value [HTTP::path]]\n" >> $tclfile
  printf "\t\t\t\t}\n" >> $tclfile
  printf "\t\t\t}\n" >> $tclfile
  printf "\t\t\telse {\n" >> $tclfile
  printf "\t\t\t\tHTTP::redirect \$value\n" >> $tclfile
  printf "\t\t\t}\n" >> $tclfile
  printf "\t\t\tbreak\n" >> $tclfile
  printf "\t\t}\n" >> $tclfile
  printf "\t}\n" >> $tclfile
  printf "}" >> $tclfile
fi