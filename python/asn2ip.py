import requests
from arguments import Arguments
from sys import argv as command_args

arinjson = lambda x : requests.get("http://whois.arin.net/ui/query.do?queryinput={}".format(x),headers={"Accept":"application/json"},verify=False).json()

ARGS = Arguments(command_args)

if not ARGS.Get('a'):
  print "usage: asn2ip.py -a <ASN>"
else:
  data = arinjson(ARGS.Get('a'))
  neturl = str("{}/nets".format(data['ns4:pft']['org']['ref']['$']))
  resp = requests.get(neturl,headers={'Accept':'application/json'}).json()
  for net in resp['nets']['netRef']:
    print "{}-{} ({})".format(net['@startAddress'],net['@endAddress'],net['$'])