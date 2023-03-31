#Requires Python 3.6

from arguments import Arguments
import requests
import tarfile
import io
import re
import sys

def usage():
  print("usage: clamav_json_dump.py -o <json-file>")
  print("             if <json-file> exists it will be overwritten")

args = Arguments(sys.argv)

if not args.Get('o'):
  usage()
  sys.exit()

with open(args.Get('o'),'w') as csvfile:
  csvfile.write('name\thash\tsize\tfile\n')

  for cvdfile in [{'name':'main','num':'1'},{'name':'daily','num':'2'}]:
    resp = requests.get('http://database.clamav.net/{}.cvd'.format(cvdfile['name']),stream=True)
    bytefile = io.BytesIO(resp.content[512:])
    tar = tarfile.open(fileobj = bytefile)
    hdbtext = tar.extractfile('{}.hdb'.format(cvdfile['name'])).read()
    for hashline in [[a[2:].split(':')[2],a[2:].split(':')[0],a[2:].split(':')[1],cvdfile['num']] for a in str(hdbtext.decode("utf-8")).split('\\n') if len(a[2:].split(':')) == 3]:
      csvfile.write('{}\t{}\t{}\t{}\n'.format(hashline[0],hashline[1],hashline[2],hashline[3]))
  csvfile.close()