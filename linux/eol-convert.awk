BEGIN {
	if (!op) {
		print "usage: awk -v op=\"<uw|um|wu|wm|mu|mw>\" -f eol-convert.awk"
		exit;
	}
	RS="|"
}
{
	if (op == "uw") {
		if ($0 == "0a") printf("0d0a");
		else printf("%s",$0);
	}
	if (op == "um") {
		if ($0 == "0a") printf("0d");
		else printf("%s",$0);
	}
	if (op == "wu") {
		if ($0 == "0d") {
			b1 = $0;
			getline;
			b2 = $0;
			if (b2 == "0a") printf("0a");
			else printf("%s%s",b1,b2);
		}
		else printf("%s",$0);
	}
	if (op == "wm") {
		if ($0 == "0d") {
			b1 = $0;
			getline;
			b2 = $0;
			if (b2 == "0a") printf("0d");
			else printf("%s%s",b1,b2);
		}
		else printf("%s",$0);
	}
	if (op == "mw") {
		if ($0 == "0d") printf("0d0a");
		else printf("%s",$0);
	}
	if (op == "mu") {
		if ($0 == "0d") printf("0a");
		else printf("%s",$0);
	}
}
