#!/bin/bash

######################
# Installation:
#   1) Create the following symbolic links to notifications.sh
#       - notifications-battery.sh
#       - notifications-cpu.sh
#       - notifications-datetime.sh
#       - notifications-mem.sh
#       - notifications-swap.sh
#
#   2) Assign keyboard shortcuts to execute the specific shell scripts to
#      display informational notifications
######################

cpu() {
  notify-send "CPU Load Average" "$(cat /proc/loadavg)"
}

mem() {
  notify-send "Memory Usage" "$(free -h | awk '/^Mem:/ { printf("%s/%s",$4,$2); }')"
}

swap() {
  notify-send "Swap Usage" "$(free -h | awk '/^Swap:/ { printf("%s/%s",$4,$2); }')"
}

datetime() {
  notify-send "Date/time" "$(date)"
}

battery() {
  notify-send "Battery state" "$(acpi)"
}

$(basename $0 | sed 's/notifications-\([^\.]\+\)\.sh$/\1/g')