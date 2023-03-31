######################################################
#
# Downloads information about a Github users Gists as a tab-delimited text file
#
# Requires arguments.py (https://gist.github.com/bng44270/871cb48d3516b6f5a1bca405959a4674)
#
# Usage:
#
#   gist2txt.py -u <username> -f <output-txt-file>
#
######################################################

from requests import get as http_get
from arguments import Arguments

ARGS = Arguments()

if not ARGS.Get('u') and not ARGS.Get('f'):
  print("usage: gist2txt.py -u <username> -f <output-txt-file>")
else:
  gist_user = ARGS.Get('u')
  out_file = ARGS.Get('f')
  
  with open(out_file,'w') as file:
    current_page = 1

    while True:
      resp = http_get('https://api.github.com/users/{}/gists?per_page=100&page={}'.format(gist_user,str(current_page)))
      
      if resp.status_code == 200:
        data = resp.json()
        
        for this_gist in data:
          filename = [a for a in this_gist['files'].keys()][0]
          file.write('{}\t{}\t{}\n'.format(this_gist['description'],filename,this_gist['html_url']))
        
        if len(data) == 0:
          break
        
        current_page = current_page + 1
      else:
        print("Error:  {}".format(resp.text))
        break

