#!/bin/bash

TARFILE=$(curl -s http://cr.yp.to/ucspi-tcp/install.html | sed 's/"/"\n/g' | grep '^ucspi.*gz' | sed 's/.$//')
DIRNAME=$(echo $TARFILE | sed 's/\.tar\.gz$//g')
wget http://cr.yp.to/ucspi-tcp/$TARFILE
tar -xvf $TARFILE
cd $DIRNAME

# Fix for CentOS/RHEL
rhfound=$(egrep -i 'centos|rhel|redhat' /etc/*release*)
if [ -n "$rhfound" ]; then
	mv conf-cc conf-cc.orig
	sed 's/^\(gcc.*\)$/\1 -include \/usr\/include\/errno.h/g' conf-cc.orig > conf-cc
fi

make