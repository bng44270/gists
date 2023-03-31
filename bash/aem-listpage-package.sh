#!/bin/bash -x

#########################################################
# This script will take the output from the CQ listpage
# tool and download a package for each node listed
#########################################################

PROTO="http"
SERVER="localhost:4502"
AUTH="admin:admin"
PKGNAME="contentpackage"
PKGGROUP="my_packages"
VERSION="1"
DATAPATH="/content"
DLPATH="./download"

mkdir $DLPATH

grep "^$DATAPATH" packagelist.txt | grep -v "'" | awk 'BEGIN { linenum=1 } { print linenum " " $0 ; linenum++ }' | while read line; do
	LINENUMBER="$(awk '{ print $1 }' <(echo $line))"
	PKGPATH="$(sed 's/^[0-9]* //g' <(echo $line))"
	curl -u $AUTH -X POST ${PROTO}://${SERVER}/crx/packmgr/service/.json/etc/packages/${PKGNAME}_${LINENUMBER}.zip?cmd=create -d packageName=${PKGNAME}_${LINENUMBER} -d groupName=$PKGGROUP -d version=1
	curl -u $AUTH -X POST -F "path=/etc/packages/${PKGGROUP}/${PKGNAME}_${LINENUMBER}.zip" -F "packageName=${PKGNAME}_${LINENUMBER}" -F "groupName=$PKGGROUP" -F "version=$VERSION" -F "filter=[{\"root\":\"$PKGPATH\",\"rules\":[]}]" -F "_charset_=UTF-8"  https://author.uc.edu/crx/packmgr/update.jsp
	curl -u $AUTH -X POST ${PROTO}://${SERVER}/crx/packmgr/service/.json/etc/packages/${PKGGROUP}/${PKGNAME}_${LINENUMBER}-${VERSION}.zip?cmd=build
	curl -u $AUTH ${PROTO}://${SERVER}/etc/packages/${PKGGROUP}/${PKGNAME}_${LINENUMBER}-${VERSION}.zip > ${DLPATH}/${PKGNAME}_${LINENUMBER}.zip
	curl -u $AUTH -X POST ${PROTO}://${SERVER}/crx/packmgr/service/.json/etc/packages/${PKGGROUP}/${PKGNAME}_${LINENUMBER}-${VERSION}.zip?cmd=delete
done