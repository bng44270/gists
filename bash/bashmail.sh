#!/bin/bash

CONFFILE="$HOME/.bash-mailrc"

usage() {
	echo "usage:  bash-mail.sh [filename]"
	echo "        if filename is not defined, the users default mailbox will be used"
}

if [ -z "$@" ]; then
	if [ -z "$MAIL" ]; then
		usage
	fi
else
	MAIL="$@"
fi

if [ "$1" == "-h" ]; then
	usage
fi

if [ ! -f $CONFFILE ]; then
	read -p "Enter your e-mail address: " yourmail
	echo "FromAddr: $yourmail" > $CONFFILE
fi

while true; do
	MSGCOUNTER="1"

	clear
	echo "Messages"
	echo "********"

	awk 1 ORS='|NL|' $MAIL | sed 's/|NL|From /\nFrom /g' | awk '{ printf $0 "\n" }' | while read line; do
		subject="$(echo "$line" | sed 's/|NL|/\n/g' | grep -m1 '^Subject' | sed 's/^Subject: //g')"
		echo "$MSGCOUNTER) $subject"
		export MSGCOUNTER="$(echo $MSGCOUNTER+1 | bc)"
	done | tee /tmp/listing-$USER

	[[ "$(wc -l /tmp/listing-$USER | awk '{ print $1 }')" == "0"  ]] && echo "No files in mailbox"
	rm /tmp/listing-$USER

	echo ""
	echo "N - New Message, R -> Reply, P -> Purge Inbox, D -> Delete, Q -> Quit"
	echo ""
	read -p "> " msgtoview
	
	if [ "$msgtoview" == "Q" ] || [ "$msgtoview" == "q" ]; then
		break
	fi

	if [ "$msgtoview" == "N" ] || [ "$msgtoview" == "n" ]; then
		msgfrom=$(cat $CONFFILE | grep 'FromAddr' | sed 's/^.*:[ \t]*//')
		read -p "Enter recipient: " msgrecip
		read -p "Enter Subject: " msgsub
		echo "Enter body of message (Ctrl-D when done)"
		msgbody=$(cat)
		printf "From: $msgfrom\nSubject: $msgsub\n\n$msgbody\n" > /tmp/msg-$USER
		read -p "Send message? (Y/N) " -s -n 1 oktosend
		if [ "$oktosend" == "Y" ] || [ "$oktosend" == "y" ]; then
			cat /tmp/msg-$USER | sendmail $msgrecip
			if [ $? -eq 0 ]; then
				echo "Message sent successfully"
			else
				echo "Error sending message"
			fi
		fi
		
		read -p "Press any key to continue." -s -n 1 donothing
		rm /tmp/msg-$USER
	fi

	if [ "$msgtoview" == "R" ] || [ "$msgtoview" == "r" ]; then
		echo "Specify Message"
                read -p "> " msgtoreply

		MSGCOUNTER="1"
	        msgorig=$(awk 1 ORS='|NL|' $MAIL | sed 's/|NL|From /\nFrom /g' | awk '{ printf $0 "\n" }' | while read line; do
			if [ "$msgtoreply" == "$MSGCOUNTER" ]; then
                		echo $line | sed 's/|NL|/\n/g' | sed 's/^/> /g'
	                        break
	                else
	                        export MSGCOUNTER="$(echo $MSGCOUNTER+1 | bc)"
	                        continue
	                fi
		done)
		
		msgfrom=$(cat $CONFFILE | grep 'FromAddr' | sed 's/^.*:[ \t]*//')
		msgrecip=$(printf "$msgorig\n" | grep '^> From:' | sed 's/^> .*<//g;s/<.*$//g')
		msgsub=$(printf "$msgorig\n" | grep '^Subject:' | sed 's/^Subject: //g;s/^/Re: /g')
                echo "Enter body of message (Ctrl-D when done)"
                msgbody=$(cat)
                printf "From: $msgfrom\nSubject: $msgsub\n\n$msgbody\n\n$msgorig\n" > /tmp/msg-$USER
                read -p "Send message? (Y/N) " -s -n 1 oktosend
                if [ "$oktosend" == "Y" ] || [ "$oktosend" == "y" ]; then
                        cat /tmp/msg-$USER | sendmail $msgrecip
                        if [ $? -eq 0 ]; then
                                echo "Message sent successfully"
                        else
                                echo "Error sending message"
                        fi
                fi

		read -p "Press any key to continue." -s -n 1 donothing
                rm /tmp/msg-$USER
	fi

	if [ "$msgtoview" == "P" ] || [ "$msgtoview" == "p" ]; then
		echo "This will remove all items from your inbox"
		read -p "Are you sure? (Y/N) " -s -n 1 oktodel
		if [ "$oktodel" == "Y" ] || [ "$oktodel" == "y" ]; then
			cat /dev/null > $MAIL
		fi
	fi
	
	if [ "$msgtoview" == "D" ] || [ "$msgtoview" == "d" ]; then
		echo "Specify Message to delete"
		read -p "> " msgtodel
	
		awk 1 ORS='|NL|' $MAIL | sed 's/|NL|From /\nFrom /g' | awk '{ printf $0 "\n" }' | while read line; do
        	        if [ "$msgtodel" == "$MSGCOUNTER" ]; then
				continue
				export MSGCOUNTER="$(echo $MSGCOUNTER+1 | bc)"
	                else
				echo $line | sed 's/|NL|/\n/g'
				echo ""
				export MSGCOUNTER="$(echo $MSGCOUNTER+1 | bc)"
	                fi
	        done > /tmp/mailbox-$USER

		cat /tmp/mailbox-$USER > $MAIL
		rm /tmp/mailbox-$USER
	
		echo "Message Deleted"
		read -p "Press any key to continue" -s -n 1 donothing
	fi

	MSGCOUNTER="1"
	awk 1 ORS='|NL|' $MAIL | sed 's/|NL|From /\nFrom /g' | awk '{ printf $0 "\n" }' | while read line; do
		if [ "$msgtoview" == "$MSGCOUNTER" ]; then
	                echo $line | sed 's/|NL|/\n/g' | less
			break
		else
			export MSGCOUNTER="$(echo $MSGCOUNTER+1 | bc)"
			continue
		fi
	done
done