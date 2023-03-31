#!/bin/bash

###########################
# CGI Github Webhook target for debugging JSON POST data
# 
# Requirements:
#     JSON.sh (from https://github.com/dominictarr/JSON.sh)
#
# Usage:
# 
#     URL: http://server/path/to/hookdebug.sh
#     Response: List of JSON attributes
#         example:
#             ...
#             ["repository","name"] "gist-client-android"
#             ...
#
#     URL: http://server/path/to/hookdebug.sh?repository-name
#     Response: List specific attribute(s) within JSON data
#         example:
#             ["repository","name"] "gist-client-android"
###########################

ENVBIN="/opt"

echo "Content-type: text/plain"
echo ""

if [ -n "$QUERY_STRING" ]; then
        ATTRIBNAME=$(echo "$QUERY_STRING" | sed 's/=$//g')
        cat - | $ENVBIN/JSON.sh | grep "$(echo "$ATTRIBNAME" | sed 's/^/["/g;s/-/","/g;s/$/"]/g;s/"\([0-9]\+\)"/\1/g;s/\[/\\\[/g;s/]/\\\]/g')"
else
        cat - | $ENVBIN/JSON.sh
fi