set appname to ""
set keypass to ""

repeat
	set appname to text returned of (display dialog "Enter application name" default answer "")
	if (length of appname) > 0 then exit repeat
end repeat

repeat
	set keypass to text returned of (display dialog "Enter key password" default answer "" with hidden answer)
	if (length of keypass) > 0 then exit repeat
end repeat

do shell script "ssh-keygen -b 2048 -t rsa -N " & keypass & " -f ~/" & appname & ".key"
do shell script "zip -jr ~/Desktop/" & appname & ".zip ~/" & appname & ".key*"
do shell script "rm ~/" & appname & ".key*"