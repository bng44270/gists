#!/bin/bash

############################################
# This requires the following directive in the rsyslogd.conf file above the:
#
#       $ModLoad imfile
#
# This should be added above the $IncludeConfig /etc/rsyslog.d/*.conf statement
############################################

if [ -z "$1" ]; then
        echo "usage: rsyslog-file-monitor.sh <conf-file>"
else
        filepath=$(read -p "Enter file to monitor: " thisfile; echo $thisfile)
        filetag=$(basename $filepath | sed 's/[^a-zA-Z0-9]//g')
        dest=$(while true; do
                read -n1 -s -p "Send to 1) Syslog Server, 2) Local Log, 3) Both: " resp
                if [ "$resp" == "1" ] || [ "$resp" == "2" ] || [ "$resp" == "3" ]; then
                        echo $resp
                        break
                fi
        done)

        echo "\$InputFileName $filepath" > $@
        echo "\$InputFileTag $filetag" >> $@
        echo "\$InputFileStateFile $filetag" >> $@
        echo "\$InputRunFileMonitor" >> $@

        echo ""

        if [ "$dest" == "1" ] || [ "$dest" == "3" ]; then
                echo "if \$syslogtag == '$filetag' then @@$(read -p "Enter Server Hostname/IP: " destip; echo $destip):$(read -p "Enter Server Port: " destport; echo $destport)" >> $@
        fi

        if [ "$dest" == "2" ] || [ "$dest" == "3" ]; then
                echo "if \$syslogtag == '$filetag' then $(read -p "Enter file path: " destpath; echo $destpath)" >> $@
        fi

        if [ -n "$(read -n1 -s -p "Copy to /etc/rsyslog.d\? (y/n) " ans; echo $ans | grep -i '^y$')" ]; then
                cp $@ /etc/rsyslog.d
        fi

        echo ""
fi