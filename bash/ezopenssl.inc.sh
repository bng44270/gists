###########################
#
# Auto-completing wrappers for OpenSSL encrypt/decrypt and hashing
#
# Usage:
#
#         ezhash <hashing-algorithm> <<< "STRING TO HASH"
#         ezhash <hashing-algorithm> < /path/to/file-to-hash
#
#         ezenc <cipher-algorithm> <<< "STRING TO ENCRYPT"
#         ezenc <cipher-algorithm> < /path/to/file-to-encrypt
#
#         ezdec <cipher-algorithm> <<< "STRING TO DECRYPT"
#         ezdec <cipher-algorithm> < /path/to/file-to-decrypt
#
# Installation:
#
#         Add the following line to .bashrc file:
#
#             source ezopenssl.inc.sh
#
###########################

complete -W "$(openssl list -digest-algorithms | sed 's/^.*[=][>][ \t]*\(.*\)$/\1/g' | sort | uniq | tr '\n' ' ')" ezhash

complete -W "$(openssl list -cipher-algorithms | sed 's/^.*[=][>][ \t]*\(.*\)$/\1/g' | sort | uniq | tr '\n' ' ')" ezenc

complete -W "$(openssl list -cipher-algorithms | sed 's/^.*[=][>][ \t]*\(.*\)$/\1/g' | sort | uniq | tr '\n' ' ')" ezdec

ezenc() {
  [[ -z "$1" ]] && echo "ezenc <cipher-algorithm>" || openssl enc -e -$1
}

ezhash() {
  [[ -z "$1" ]] && echo "ezhash <hashing-algorithm>" || openssl dgst -$1
}

ezdec() {
    [[ -z "$1" ]] && echo "ezdec <cipher-algorithm>" || openssl enc -d -$1
}