import requests
from arguments import Arguments
from sys import argv as command_arguments

arinjson = lambda x : requests.get("http://whois.arin.net/ui/query.do?queryinput={}".format(x),headers={"Accept":"application/json"},verify=False).json()

# print indented outline-style representation of dictionary object
def dictol(this_dictionary):
  try:
    prefix = this_dictionary['pf']
  except:
    prefix = ''
  
  try:
    if 'float' in str(type(this_dictionary['value'])) or 'int' in str(type(this_dictionary['value'])):
      print '{}{}: {}'.format(prefix,this_dictionary['name'],str(this_dictionary['value']))
    elif 'str' in str(type(this_dictionary['value'])) or 'unicode' in str(type(this_dictionary['value'])):
      print '{}{}: "{}"'.format(prefix,this_dictionary['name'],str(this_dictionary['value']))
    elif 'list' in str(type(this_dictionary['value'])) or 'tuple' in str(type(this_dictionary['value'])):
      print '{}{}:'.format(prefix,this_dictionary['name'])
      for thisitem in this_dictionary['value']:
        dictol({'pf':'  {}'.format(prefix),'name':'[{}]'.format(str(this_dictionary['value'].index(thisitem))),'value':thisitem,})
    elif 'dict' in str(type(this_dictionary['value'])):
      print '{}{}: '.format(prefix,this_dictionary['name'])
      for thisitem in this_dictionary['value'].items():
        dictol({'pf':'  {}'.format(prefix),'name':thisitem[0],'value':thisitem[1]})
  except:
    dictol({'name':[k for k,v in locals().items() if v == this_dictionary][0], 'value':this_dictionary})

# Main Logic
ARGS = Arguments(command_arguments)

if not ARGS.Get('i'):
  print "usage: arin.py -i <search-item>"
  print "          search-item => IP address or ASN"
else:
  dictol(arinjson(ARGS.Get('i')))