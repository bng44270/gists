#!/bin/bash

########################################
# pullsite.sh
#
# Requirements:
#   1. All sites are contained in Git repos
#   2. Local copy of repository is located on web server within folder $SITESHOME (change this variable as necessary)
#   3. Website user needs write access to $SITESHOME
#
# Installation:
#   1. Place file on web server
#   2. Change file mode to 755
#   3. Add Webhook to repository http://url/path/to/pullsite.sh
#
# Other:
#   - Modify reponame.log file to line length of $MAXFILELEN (change this variable as necessary
#
########################################

MAXFILELEN="1000"
SITESHOME="/srv/www
[[ ! -d $SITESHOME/git-logs ]] && mkdir $SITESHOME/git-logs

echo "Content-type: text/html"
echo ""

if [ "$REQUEST_METHOD"=="POST" ]; then
        reponame=$(cat - | sed 's/,/,\n/g' | grep '^[ \t]*"full_name"' | sed 's/^.*\///g;s/".*$//g')
        cd $SITESHOME/$reponame
        result=$(git pull)
        if [ $? -eq 0 ]; then
                nomod=$(echo $result | grep -i 'already up[- ]*to[- ]*date')
                if [ -n "$nomod" ]; then
                        echo "$(date) - $reponame - no changes" | tee -a $SITESHOME/git-logs/$reponame.log
                else
                        echo "$(date) - $reponame - success" | tee -a $SITESHOME/git-logs/$reponame.log
                fi
        else
                echo "$(date) - $reponame - failed" | tee -a $SITESHOME/git-logs/$reponame.log
        fi

        if [ $(wc -l $SITESHOME/git-logs/$reponame.log) -gt 1000 ]; then
                tail -n$MAXFILELEN $SITESHOME/git-logs/$reponame.log > $SITESHOME/git-logs/$reponame.tmp
                mv $SITESHOME/git-logs/$reponame.tmp $SITESHOME/git-logs/$reponame.log
                echo "Truncating log file"
        fi
fi