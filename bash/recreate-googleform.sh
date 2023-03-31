#!/bin/bash

###################################################
# This script will take a google docs form
# and create a flat HTML form that you can use to
# post via a custom IU.  Note that form elements (<div> tags)
# might need to rearranged.
#
# This handles text form fields, textarea, and select form elements
#
# Use the following CSS for basic formatting for the form:
#
#     form div {
#       top:20px;
#     }
#
#     form div span.fieldlabel {
#       left:0px;
#       top:0px;
#     }
#
#     form div input {
#       display:block;
#       position:relative;
#       left:0px;
#       top:0px;
#     }
#
#     form div textarea {
#       display:block;
#       position:relative;
#       left:0px;
#       top:0px;
#     }
#
#     form div select {
#       display:block;
#       position:relative;
#       left:0px;
#       top:0px;
#     }
###################################################


if [ -z "$1" ]; then
        echo "usage: recreate-googleform <viewform-url>"
        echo "         i.e. https://docs.google.com/<some-url>/viewform"
else
        TMPFILE="/tmp/$RANDOM.html"
        curl -s $1 | sed 's/>/>\n/g' > $TMPFILE
        posturl=$(echo $1 | sed 's/viewform/formResponse/g')
        echo "<form method=\"post\" action=\"$posturl\" target=\"_blank\">"
        egrep '<textarea.*data-initial-value|<input.*data-initial-value' $TMPFILE | grep -v 'type="hidden"' | while read line; do
                isinput=$(grep '<input' <(echo $line))
                fieldtitle=$(echo $line | sed 's/^<[a-zA-Z]* //g;s/>$//g;s/" /"\n/g' | grep '^aria-label' | sed 's/^.*="//g;s/"//g')
                fieldname=$(echo $line | sed 's/^<[a-zA-Z]* //g;s/>$//g;s/" /"\n/g' | grep 'name="entry' | sed 's/^.*="//g;s/"//g')
                if [ -n "$isinput" ]; then
                        echo -e "<div>\n<span class=\"fieldlabel\">$fieldtitle</span>\n<input type=\"text\" name=\"$fieldname\"/>\n</div>"
                else
                        echo -e "<div>\n<span class=\"fieldlabel\">$fieldtitle</span>\n<textarea name=\"$fieldname\"></textarea>\n</div>"
                fi
        done
        grep '<input.*hidden.*entry' $TMPFILE | sed 's/^.* jsname="//g;s/".*$//g' | sort | uniq | while read line; do
                grep "<input.*$line" $TMPFILE | sed 's/"/\\"/g' | while read inputline; do
                        fieldtitle=$(grep -B100 "$inputline" $TMPFILE | grep -B1 '^*' | tail -n2 | head -n1 | sed 's/<span.*$//g')
                        fieldname=$(sed 's/^.* name="//g;s/".*$//g' <(echo $inputline))
                        echo -e "<div>\n<span class=\"fieldlabel\">$fieldtitle</span>\n<select name=\"$fieldname\">"
                        grep -B70 "$inputline" $TMPFILE | grep -A100 "<div.*$line" | grep '</content>' | grep -v '^Choose' | sed 's/<\/content>//g' | while read option; do
                                echo "<option value=\"$option\">$option</option>"
                        done
                        echo -e "</select>\n</div>"
                done
        done
        echo "<input type=\"submit\" />"
        echo "</form>"
fi