import requests
from re import sub as regex_sub
from re import match as regex_match

# Return every "i" value in array "x"
everyother = lambda x,i : [a for a in x if x.index(a) % i == 0]

# Similar to the JavaScript slice function.  Usage:  slice(<array>,<beginning-index>,<length>)
slice = lambda a,i,l : a[i:(i+l)]

# format integer as a string with comma separation.  Usage
formatint = lambda x : regex_sub(r',$','',regex_sub(r'([0-9]{3})','\\1,',str(x)[::-1]))[::-1]

# Parse strings containing comma's/decimal points into int/float
parse_comma_int = lambda x : int(regex_sub(r',','_',x))
parse_comma_float = lambda x : float(regex_sub(r',','_',x))

# Return type of variable (similar to JavaScript typeof operator)
typeof = lambda v : type(v).__name__

# Return a number (x) in scientific notation to a specific decimal precision (y) 
scinote = lambda x,y: '{}.{}e{}'.format(str(int(x/(10**(len(str(x))-1)))),str(x)[1:y+1],str(len(str(x))-1))

# Return factorial value of a number
factorial = lambda x : eval("*".join([str(a) for a in range(1,x+1)]))

# Get users current geolocation
getmyloc = lambda : {k:v for (k,v) in requests.get('http://ifconfig.co/json').json().items() if k=='latitude' or k=='longitude'}

# Get geolocation of a specific IP address
getloc = lambda x : {k:v for (k,v) in requests.get('http://ip-api.com/json/' + x).json().items() if k=='lat' or k=='lon'}

# Get Domain information via Google DNS
gdns = lambda x,y='' : requests.get('https://dns.google/resolve?name=' + x + ('&type=' + y if len(y)>0 else '')).json()

# Resolve IP Address of domain using Google DNS
resolveip = lambda x : [str(a['data']) for a in gdns(x,'A')['Answer'] if a['type'] == 1]

# Get Geolocation of DNS Name
dnsiploc = lambda x : [{"ip":a,"lat":getloc(a)['lat'],"lon":getloc(a)['lon']} for a in resolveip(x)]

# calculate pi using the Gregory-Leibniz Series
glspi = lambda x : (eval('+'.join([str(1/float(a)) for idx, a in enumerate(range(1,x,2)) if idx % 2 == 0])) - eval('+'.join([str(1/float(a)) for idx, a in enumerate(range(1,x,2)) if idx % 2 != 0])))*4

# found at https://stackoverflow.com/questions/31045518/finding-prime-numbers-using-list-comprehention
primes = lambda x : [a for a in range(2, x) if all(a % b != 0 for b in range(2,a))]

# Get Current Github Enterprise version
ghe_version = lambda : str([regex_sub('^.*id="release-([^"]+)".*$',"\\1",a) for a in requests.get('https://enterprise.github.com/releases').text.split('\n') if '<div class="release"' in a][0])

# Get current Debian version
debian_version = lambda : str([regex_sub('^.*Debian[ \t]*([0-9\.]+).*$','\\1',a) for a in requests.get('https://www.debian.org/releases/stable/').text.split('\n') if regex_match('^.*Debian[ \t]*[0-9]',a)][0])

# Get current Apache Web Server version
httpd_version = lambda : str([regex_sub('^.*httpd[ \t]*([0-9\.]+)[ \t]*Released.*$','\\1',a) for a in requests.get('https://httpd.apache.org/').text.split('\n') if regex_match('^.*Released',a)][0])

# Get current Monit version
monit_version = lambda : str([regex_sub(r'^.*Monit[ \t]*([0-9\.]+)[ \t]*Downloads.*$','\\1',a) for a in requests.get('https://mmonit.com/monit/').text.split('\n') if regex_match(r'^.*Monit.*Downloads.*$',a)][0])

# Get current SNMP version
snmp_version = lambda : str([regex_sub(r'^.*Current release:[ \t]*([0-9\.]+).*$','\\1',a) for a in requests.get('http://www.net-snmp.org/').text.split('\n') if regex_match(r'^.*Current release.*$',a)][0])

# Get current OpenSSH version
ssh_version = lambda : str([regex_sub(r'^.*OpenSSH[ \t]*([0-9\.]+)<.*$','\\1',a) for a in requests.get('https://www.openssh.com/').text.split('\n') if regex_match(r'^.*released.*$',a)][0])

# Get current OpenSSL version
ssl_version = lambda : str([regex_sub(r'^[ \t]+openssl-([0-9\.]+).*$','\\1',a) for a in requests.get('https://github.com/openssl/openssl/tags').text.split('\n') if regex_match(r'^[ \t]+openssl-[0-9\.]+.*$',a)][0])

# Get current TinyCore Linux version
tinycore_version = lambda : str([regex_sub(r'^.*The latest version:[ \t]*<[\/]*[a-z]*[\/]*>([0-9\.]+)<.*$','\\1',a) for a in requests.get('http://tinycorelinux.net/').text.split('\n') if regex_match(r'^.*The latest version:.*$',a)][0])

# Get current PHP version
def php_version():
  respar = requests.get('http://php.net/downloads.php').text.split('\n')
  return str(regex_sub(r'^.*PHP[ \t]*([0-9\.]+).*$','\\1',respar[[a for a,b in enumerate(respar) if regex_match(r'^.*Current Stable.*$',b)][0]+1]))

# Get current Linux Kernel version
def kernel_version():
  respar = requests.get('https://www.kernel.org').text.split('\n')
  return str([regex_sub(r'^.*>([0-9\.]+)<.*$','\\1',b) for a,b in enumerate(respar) if a == int([c for c,d in enumerate(respar) if regex_match(r'^.*stable.*$',d)][0]+1)][0])
  
# return IP or ASN whois data of "x" from ARIN
arinjson = lambda x : requests.get("http://whois.arin.net/ui/query.do?queryinput={}".format(x),headers={"Accept":"application/json"},verify=False).json()

# return text of indented outline-style representation of dictionary object
def dictol(this_dictionary):
  returntext = ""
  try:
    prefix = this_dictionary['pf']
  except:
    prefix = ''
  try:
    if 'float' in str(type(this_dictionary['value'])) or 'int' in str(type(this_dictionary['value'])):
      returntext += '{}{}: {}\n'.format(prefix,this_dictionary['name'],str(this_dictionary['value']))
    elif 'str' in str(type(this_dictionary['value'])) or 'unicode' in str(type(this_dictionary['value'])):
      returntext +=  '{}{}: "{}"\n'.format(prefix,this_dictionary['name'],str(this_dictionary['value']))
    elif 'list' in str(type(this_dictionary['value'])) or 'tuple' in str(type(this_dictionary['value'])):
      returntext += '{}{}:\n'.format(prefix,this_dictionary['name'])
      for thisitem in this_dictionary['value']:
        returntext += dictol({'pf':'  {}'.format(prefix),'name':'[{}]'.format(str(this_dictionary['value'].index(thisitem))),'value':thisitem,})
    elif 'dict' in str(type(this_dictionary['value'])):
      returntext += '{}{}:\n'.format(prefix,this_dictionary['name'])
      for thisitem in this_dictionary['value'].items():
        returntext += dictol({'pf':'  {}'.format(prefix),'name':thisitem[0],'value':thisitem[1]})
  except:
    returntext += dictol({'name':[k for k,v in locals().items() if v == this_dictionary][0], 'value':this_dictionary})
  return returntext

# Generates first "fibcount" numbers in the fibonacci sequence
def fibseq(fibcount):
  starter = 0
  fibar = []
  
  for i in range(1,fibcount):
    fibar.append(starter)
    if len(fibar) == 1:
      fibar.append(starter+1)
    starter = fibar[len(fibar)-1] + fibar[len(fibar)-2]
  
  return fibar

# Generate random password using Correct Horse Battery Staple
def chbs(wordcount,passlength):
  wordar = requests.get('http://correcthorsebatterystaple.net/data/wordlist.txt').text.strip().split(',')
  newpass = ""
  while True:
    random.shuffle(wordar)
    newpass = "".join(wordar[0:wordcount])
    if len(newpass) == passlength:
      break
  return newpass

# Generate random content using Bacon Ipsum
def bacon(paragraphs):
  biresp = requests.get('https://baconipsum.com/?paras=' + str(paragraphs) + '&type=all-meat').text
  return re.sub('</p><p>','\n',re.sub(r'^.*"><p>(.+)</p></div>.*$',r'\1',[a for a in biresp.split('\n') if re.search('<div class="anyipsum-output">',a)][0])).split('\n')

# Generate TinyURL from a log URL
def GetTinyURL(longurl):
  r = requests.post("http://tinyurl.com/create.php", data={'url': str(longurl)})
  if r.status_code == 200:
    return re.sub("\".*$","",re.sub("^.*text=\"","",str([a for a in r.text.split('\n') if a.find("data-clipboard-text") > 0][0])))
  else:
    return False

# Return dictionary containing blocklist.de
def GetBlocklistDe():
  returndata = []
  
  dnsbl = requests.get('http://lists.blocklist.de/lists/dnsbl/all.list').text
  
  re_ipaddr = r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
  
  for block in [a for a in dnsbl.split('\n') if re.match(r'^' + re_ipaddr + r':' + re_ipaddr + r':.+$',a)]:
    ip = re.sub(re.compile(r'^(' + re_ipaddr + r'):.+$'),'\\1',block)
    msg = re.sub(re.compile(r'^' + re_ipaddr + r':' + re_ipaddr + r':(.+)$'),'\\1',block)
    returndata.append({'ip':ip,'msg':msg})
  
  return returndata