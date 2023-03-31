#Requires Python 3.6

import xml.etree.ElementTree as ET
from arguments import Arguments
import sys
from os import path
import json

args = Arguments(sys.argv)

def usage():
  print("usage: getioc.py -f <TAXII_poll_response_XML_file>")
  
if not args.Get('f'):
  print("usage: getioc.py -f <TAXII_poll_response_XML_file>")
  sys.exit()
  
taxiidata = ET.parse(args.Get('f'))

iocar = []

for contentblock in taxiidata.getroot().find('./taxii_11:Content_Block',{'taxii_11':'http://taxii.mitre.org/messages/taxii_xml_binding-1.1'}):
  content = contentblock.find('./stix:STIX_Package/stix:Indicators',{'stix':'http://stix.mitre.org/stix-1'})
  try:
    for indicator in content:
      iocar.append(indicator.find('./indicator:Title',{'indicator':'http://stix.mitre.org/Indicator-2'}).text.split(' from '))
  except:
    if not content is None:
      iocar.append(content.find('./indicator:Title',{'stix':'http://stix.mitre.org/stix-1','indicator':'http://stix.mitre.org/Indicator-2'}).text.split(' from '))

print(json.dumps([{'ioc':a[0],'url':a[1]} for a in iocar]))