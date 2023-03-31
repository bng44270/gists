#qpy:console

#################################
#
# This is a very minimal QPython script to access Github Gists
#
# for a more robust QPython application, check out https://github.com/bng44270/gist-client-android
#
#################################

import androidhelper
import requests
import re

requests.packages.urllib3.disable_warnings()

def ParseGistURL(url):
  returndata = { "nexturl" : "", "gists" : []}
  html = requests.get(url)
  for thisline in html.iter_lines():
    if re.search("css-truncate-target",thisline):
      if not re.search(">" + gituser + "<",thisline):
        gistline = str(re.sub("^","https://gist.github.com",re.sub("<.*$","",re.sub("\".*css-truncate-target\">","|",re.sub("^.*href=\"","",thisline))))).split("|")
        returndata["gists"].append({ "url":gistline[0], "name":gistline[1]})
    if re.search(">Newer<.*href=.*>Older<",thisline):
      returndata["nexturl"] = re.sub("\".*$","",re.sub("^.*href=\"","",thisline))
      break
    
  return returndata


droid = androidhelper.Android()
inputresp = droid.dialogGetInput("","Enter Github Username")
gituser = str(inputresp.result)
gisturl = "https://gist.github.com/" + gituser

f = open("/storage/sdcard0/Download/python/gists.html","w")
f.write("<!DOCTYPE HTML>\n")
f.write("<html>\n")
f.write("<head>\n")
f.write("<meta name=\"viewport\" id=\"viewport\" content=\"width=device-width, target-densitydpi=device-dpi, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0\" />\n")
f.write("</head>\n")
f.write("<body>\n")
f.write("<b>Gists:</b><br/>")
while True:
  gistdata = ParseGistURL(gisturl)
  for thisgist in gistdata["gists"]:
    f.write('<a href="' + thisgist["url"] + '" target="_blank">' + thisgist["name"] + '</a><br/>\n')
  if len(gistdata["nexturl"]) > 0:
    gisturl = gistdata["nexturl"]
  else:
    break

f.write("</body>\n")
f.write("</html>")
f.close()

droid.viewHtml("/storage/sdcard0/Download/python/gists.html")