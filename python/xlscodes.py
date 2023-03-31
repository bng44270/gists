from arguments import Arguments
from sys import argv as command_args

def xlsloadcodes(filename):
  with open(filename,'r') as f:
    filelines = f.readlines()
  
  return [{'code':a.split(' ')[0],'value':a.split(' ')[1].strip()} for a in filelines]

def xlsmakeif(cell,codes):
  if len(codes) > 0:
    return 'if(exact({},"{}"),"{}",{})'.format(cell,codes[0]['code'],codes[0]['value'],xlsmakeif(cell,codes[1:]))
  else:
    return '"ERR"'

ARGS = Arguments(command_args)

if not ARGS.Get('c') or not ARGS.Get('f'):
  print "usage: xlscodes.py -c <cell> -f <code-file>"
else:
  codes = xlsloadcodes(ARGS.Get('f'))
  if len(codes) > 64:
    print "Error: {} codes found.  Limit is 64".format(len(codes))
  else:
    print "={}".format(xlsmakeif(ARGS.Get('c'),codes))