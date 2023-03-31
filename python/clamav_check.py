#Requires Python 3.6

from arguments import Arguments
import requests
import tarfile
import io
import sys

def usage():
  print("usage: clamav_check.py -h <hash> -f <daily|main>")

args = Arguments(sys.argv)

if not args.Get('f') or not args.Get('h'):
  usage()
  sys.exit()

if not args.Get('f') in ['daily','main']:
  print("Invalid file name (" + args.Get('f') + ")")
  usage()
  sys.exit()

resp = requests.get('http://database.clamav.net/' + args.Get('f') + '.cvd',stream=True,headers={'User-agent':'CVDUPDATE'})

bytefile = io.BytesIO(resp.content[512:])

tar = tarfile.open(fileobj = bytefile)
	
hdbtext = tar.extractfile(args.Get('f') + '.hdb').read()

hdbar = [{'id':a[2:].split(':')[0],'size':a[2:].split(':')[1], 'name':a[2:].split(':')[2]} for a in str(hdbtext).split('\\n') if len(a[2:].split(':')) == 3]

print([a for a in hdbar if a['id'] == args.Get('h')][0])