export PATHCOLOR="YELLOW"
export USERHOSTCOLOR="GREEN"
export PROMPTEND="$"

echo-color() {
	case $(echo $1 | tr '[:lower:]' '[:upper:]') in
		"BLACK")  tput setaf 0 ;;
		"RED")  tput setaf 1  ;;
		"GREEN")  tput setaf 2  ;;
		"YELLOW")  tput setaf 3  ;;
		"BLUE")  tput setaf 4  ;;
		"MAGENTA")  tput setaf 5  ;;
		"CYAN")  tput setaf 6  ;;
		"WHITE")  tput setaf 7  ;;
		*) tput sgr0  ;;
	esac
	cat -
	tput sgr0
}

setpathcolor() {
	if [ -n "$(echo black red green yellow blue magenta cyan white | grep -i $1)" ]; then
		export PATHCOLOR="$1"
	fi
}

setuserhostcolor() {
	if [ -n "$(echo black red green yellow blue magenta cyan white | grep -i $1)" ]; then
		export USERHOSTCOLOR="$1"
	fi
}

setpromptend() {
	export PROMPTEND="$@"
}

alias getpath='printf "$(pwd)" | sed "s|$HOME|~|g"'
export PS1="\$(printf \"[\$USERNAME@\$HOSTNAME]\" | echo-color \$USERHOSTCOLOR) \$(getpath | echo-color \$PATHCOLOR) \$PROMPTEND "