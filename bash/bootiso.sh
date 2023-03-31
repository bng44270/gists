#!/bin/bash

#######################################
#
# Installation:
#   <ROOT>/bin/bootiso.sh
#   <ROOT>/etc/bootiso.conf
#
# Config file format (bootiso.conf)
#
# For each ISO Image enter two lines in
# configuration file
#
# <ID>_IMG <PATH-TO-ISO>
# <ID>_MEM <NUMBER><M|G>
#
# <ID> is a unique identifier for the boot environment.
# The first line specifies the path to the ISO image
# The second line specified the memory for the VM to use
# for booting the ISO
#
# EXAMPLE:
#
#     Config file:
#
#         KALI_IMG /path/to/kali-linux-2022.2-live-amd64.iso 
#         KALI_MEM 8G
#
#     Create script link:
#
#         ln -s <ROOT>/bin/bootiso.sh <ROOT>/bin/bootiso-KALI.sh
#
#     Booting ISO:
#
#         <ROOT>/bin/bootiso-KALI.sh
#
#######################################

CONFFILE="$(dirname $0)/../etc/bootiso.conf"

eval $(sed 's/^\([^ \t]\+\)[ \t]\+\(.*\)$/\1="\2"/g' < $CONFFILE)

BOOTING="$(basename $0 | sed 's/^bootiso-//g;s/\.sh$//g')"
ISO="${BOOTING}_IMG"
MEM="${BOOTING}_MEM"

qemu-system-x86_64 -enable-kvm -cdrom ${!ISO} -m ${!MEM}