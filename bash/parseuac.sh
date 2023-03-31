#!/bin/bash

##############################################
# Based on AD UserAccountControl attribute
# values that can be found at:
#
# https://support.microsoft.com/en-us/help/305144/how-to-use-useraccountcontrol-to-manipulate-user-account-properties
##############################################

if [ -z "$1" ]; then
	echo "usage: parseuac.sh <uac-value>"
else
	echo "ibase=10;obase=2;$1" | bc | rev | sed 's/\(.\)/\1\n/g' | \
	awk '/^[^ \t]+$/ {
		if ($1 == 1) {
			if (NR == 1) print "SCRIPT"
			if (NR == 2) print "ACCOUNTDISABLE"
			if (NR == 4) print "HOMEDIR_REQUIRED"
			if (NR == 5) print "LOCKOUT"
			if (NR == 6) print "PASSWD_NOTREQD"
			if (NR == 7) print "PASSWD_CANT_CHANGE"
			if (NR == 8) print "ENCRYPTED_TEXT_PWD_ALLOWED"
			if (NR == 9) print "TEMP_DUPLICATE_ACCOUNT"
			if (NR == 10) print "NORMAL_ACCOUNT"
			if (NR == 12) print "INTERDOMAIN_TRUST_ACCOUNT"
			if (NR == 13) print "WORKSTATION_TRUST_ACCOUNT"
			if (NR == 14) print "SERVER_TRUST_ACCOUNT"
			if (NR == 17) print "DONT_EXPIRE_PASSWORD"
			if (NR == 18) print "MNS_LOGON_ACCOUNT"
			if (NR == 19) print "SMARTCARD_REQUIRED"
			if (NR == 20) print "TRUSTED_FOR_DELEGATION"
			if (NR == 21) print "NOT_DELEGATED"
			if (NR == 22) print "USE_DES_KEY_ONLY"
			if (NR == 23) print "DONT_REQ_PREAUTH"
			if (NR == 24) print "PASSWORD_EXPIRED"
			if (NR == 25) print "TRUSTED_TO_AUTH_FOR_DELEGATION"
			if (NR == 27) print "PARTIAL_SECRETS_ACCOUNT"
		}
	}'
fi
