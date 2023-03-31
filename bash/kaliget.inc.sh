####################
#
# Usage:
#
#   1) Place file on Debian-based system
#
#   2) Add the following line to .bashrc
#       source /path/to/kaliget.inc.sh
#
#   3) To install Kali packages run:
#         kaliget PACKAGE
#
#      To list packages use:
#         kaliget <TAB>
#
#################### 

# Install Kali Linux Repo 
if [ ! -f /etc/apt/sources.list.d/kali.list ]; then
  sudo tee /etc/apt/sources.list.d/kali.list <<HERE
deb https://http.kali.org/kali kali-rolling main non-free contrib
HERE
  sudo apt-get update
fi

complete -W "$(apt-cache search kali-tools- | sed 's/^kali-tools-\([^ \t]\+\)[ \t]*.*$/\1/g' | tr '\n' ' ')" kaliget

function kaliget() {
  apt install kali-tools-$1
}