#***********************
#  TaxiiClient class
#    Constructor:
#      TaxiiClient(discovery_url, auth = None, cert_val = True)
#        auth => Set to dictionary to do HTTP auth {'user':'USERNAME','pass':'PASSWORD'}
#        cert_val => Sets whether or not to do SSL certificate validation
#    Methods:
#      do_doscovery()
#        - perform TAXII DISCOVERY
#      get_urls()
#        - return DISCOVERY, COLLECTION_MANAGEMENT, and POLL URLs for TAXII service_type
#      do_collection()
#        - perform TAXII COLLECTION_MANAGEMENT
#      get_collections()
#        - returns an array containing the names of all available collections
#      do_polls(start_time = <24 hours ago>,end_time = <current time>)
#        - returns TAXII POLL XML for the given collection_name
#      save_polls()
#        - saves POLL data from all TAXII collections into collection_name.taxii
#***********************
import requests
from re import sub as regex_sub
from re import search as regex_search
from time import time as get_timestamp
from time import strftime as format_time
from time import localtime as local_time
from base64 import b64encode as base64_encode


class TaxiiClient:
  def __init__(self,discovery_url,auth = None,cert_val = True):
    self.VERIFY_SSL = cert_val
    self.HEADERS = {}
    if auth:
      self.HEADERS['Authorization'] = 'Basic {}'.format(base64_encode('{}:{}'.format(auth['user'],auth['pass'])))
    self.HEADERS['Accept'] = 'application/xml'
    self.HEADERS['Content-Type'] = 'application/xml'
    self.HEADERS['X-TAXII-Accept'] = 'urn:taxii.mitre.org:message:xml:1.1'
    self.HEADERS['X-TAXII-Content-Type'] = 'urn:taxii.mitre.org:message:xml:1.1'
    self.HEADERS['Cache-Control'] = 'no-cache'
    self.HEADERS['X-TAXII-Services'] = 'urn:taxii.mitre.org:services:1.1'
    self.HEADERS['X-TAXII-Protocol'] = 'urn:taxii.mitre.org:protocol:http:1.0'
    self.HEADERS['Accept-Encoding'] = 'gzip, deflate'
    self.HEADERS['Accept-Language'] = 'en-US,en;q=0.8'
    self.DISCOVERED = False
    self.DISCOVERY = {}
    self.DISCOVERY['url'] = discovery_url
    self.DISCOVERY['payload'] = '<Discovery_Request xmlns="http://taxii.mitre.org/messages/taxii_xml_binding-1.1" message_id="1"/>'
    self.COLLECTED = False
    self.COLLECTION = {}
    self.COLLECTION['url'] = ''
    self.COLLECTION['list'] = []
    self.COLLECTION['payload'] = '<taxii_11:Collection_Information_Request xmlns:taxii_11="http://taxii.mitre.org/messages/taxii_xml_binding-1.1" message_id="26300"/>'
    self.POLL = {}
    self.POLL['url'] = ''
    self.POLL['payload'] = '<taxii_11:Poll_Request xmlns:taxii_11="http://taxii.mitre.org/messages/taxii_xml_binding-1.1" message_id="42158" collection_name="{}"><taxii_11:Exclusive_Begin_Timestamp>{}</taxii_11:Exclusive_Begin_Timestamp><taxii_11:Inclusive_End_Timestamp>{}</taxii_11:Inclusive_End_Timestamp><taxii_11:Poll_Parameters allow_asynch="false"><taxii_11:Response_Type>FULL</taxii_11:Response_Type></taxii_11:Poll_Parameters></taxii_11:Poll_Request>'
    self.POLL['data'] = []
    self.POLL['observables'] = []
    
  def do_discovery(self):
    resp = requests.post(self.DISCOVERY['url'],data = self.DISCOVERY['payload'], verify = self.VERIFY_SSL, headers = self.HEADERS)

    taxii_xml = regex_sub(r'(<taxii_11:Service_Instance)',r'\n\1',regex_sub(r'(<\/taxii_11:Service_Instance>)',r'\1\n',resp.text.replace('\n',''))).split('\n')
    
    services = []
    
    for this_line in taxii_xml:
      try:
        if regex_search(r'^<taxii_11:Service_Instance',this_line).group():
          svcar = regex_sub(r'^.* service_type="([^"]+)".*<taxii_11:Address>([^<]+)<.*$',r'\1\n\2',this_line).split('\n')
          services.append({'name':svcar[0],'url':svcar[1]})
      except:
        continue
    
    if services:
      self.DISCOVERED = True
      self.COLLECTION['url'] = [str(a['url']) for a in services if a['name'] == 'COLLECTION_MANAGEMENT'][0]
      self.POLL['url'] = [str(a['url']) for a in services if a['name'] == 'POLL'][0]
  
  def get_urls(self):
    
    if self.DISCOVERED:
      returnlist = []
      returnlist.append({'name':'DISCOVERY','url':self.DISCOVERY['url']})
      returnlist.append({'name':'COLLECTION_MANAGEMENT','url':self.COLLECTION['url']})
      returnlist.append({'name':'POLL','url':self.POLL['url']})
      return returnlist
    else:
      raise Exception('Discovery has not been performed')
    
  def do_collection(self):
    if self.COLLECTION['url']:
      resp = requests.post(self.COLLECTION['url'],data = self.COLLECTION['payload'], verify = self.VERIFY_SSL, headers = self.HEADERS)
      
      taxii_xml = regex_sub(r'(<taxii_11:Collection )',r'\n\1',regex_sub(r'(<\//taxii_11:Collection>)',r'\1\n',resp.text.replace('\n',''))).split('\n')
      
      for this_line in taxii_xml:
        try:
          if regex_search(r'^<taxii_11:Collection ',this_line).group():
            this_collection = regex_sub(r'^.* collection_name="([^"]+)".*$',r'\1',this_line)
            self.COLLECTION['list'].append(str(this_collection))
        except:
          continue

      if self.COLLECTION['list']:
        self.COLLECTED = True

  def get_collections(self):
    if self.COLLECTED:
      return self.COLLECTION['list']
    else:
      raise Exception('Collection has not been performed')

  def do_polls(self,start_time = format_time('%Y-%m-%dT%H:%M:%SZ',local_time(get_timestamp()-86400)),end_time = format_time('%Y-%m-%dT%H:%M:%SZ',local_time(get_timestamp()))):
    if self.COLLECTED:
      for collection_name in self.COLLECTION['list']:
        poll_resp = "" 
        resp = requests.post(self.POLL['url'],data = self.__poll_payload(collection_name,start_time,end_time), verify = self.VERIFY_SSL, headers = self.HEADERS)
        self.POLL['data'] = [a for a in self.POLL['data'] if a['name'] != collection_name]
        self.POLL['data'].append({'name':collection_name,'xml':resp.text})
    else:
      raise Exception('Collection has not been performed'.format(collection_name))

  def get_poll(self,collection_name):
    if [a for a in self.POLL['data'] if a['name'] == collection_name]:
      return [a['xml'] for a in self.POLL['data'] if a['name'] == collection_name][0]
    else:
      raise Exception('Poll data unavailable ({})'.format(collection_name))

  def save_polls(self):
    if self.POLL['data']:
      collection_files = []
      for this_poll in self.POLL['data']:
        file_name = '{}.taxii'.format(this_poll['name'])
        with open(file_name,'w') as f:
          f.write(this_poll['xml'])
        collection_files.append(file_name)
      return collection_files
    else:
      raise Exception('Collection has not been performed')
    
  def __poll_payload(self, collection_name, start_time, end_time):
    return self.POLL['payload'].format(collection_name,start_time,end_time)