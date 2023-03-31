#################################################
#
# USCBGeocoder - perform Address-to-LatLng geocoding using
#                US Census Bureau API
#
# Usage:
#
#    gc = USCBGeocoder()
#    gc.SetBenchmark(id=2020)
#    gc.GetCoords('401 S 2nd St',zip='62701')
#
#   OR
#
#    gc = USCBGeocoder()
#    gc.SetBenchmark(name='Public_AR_Census2020')
#    gc.GetCoords('401 S 2nd St',city='Springfield',state='IL')
#
#################################################

from requests import get  as http_get
from urllib.parse import quote as urlencode
from re import sub as regex_sub


typeof = lambda x : regex_sub(r'^.*\'([^\']+)\'.*$','\\1',str(x.__class__))

class USCBGeocoder:
  def __init__(self):
    self.__get_benchmarks()
    self.D_benchmark = -1
  
  def SetBenchmark(self,id='',name=''):
    if id in [a['id'] for a in self.benchmarks]:
      self.D_benchmark = id
      return True
    elif name in [a['name'] for a in self.benchmarks]:
      self.D_benchmark = [a['id'] for a in self.benchmarks if a['name'] == name][0]
      return True
    else:
      return False
  
  
  def GetCoords(self,addr,city='',state='',zip=''):
    if not self.D_benchmark == -1:
      query = {}
      query['street'] = urlencode(addr)
      if len(city) > 0:
        query['city'] = urlencode(city)
      if len(state) > 0:
        query['state'] = urlencode(state)
      if len(zip) > 0:
        query['zip'] = urlencode(zip)
      
      query_string = self.__get_query_string(query)
      
      resp = http_get('https://geocoding.geo.census.gov/geocoder/locations/address?benchmark={}&format=json&{}'.format(str(self.D_benchmark),query_string))
      
      if resp.status_code == 200:
        coord = resp.json()['result']['addressMatches'][0]['coordinates']
        return {"lat":coord['y'],"lng":coord['x']}
      else:
        print("http")
        return False
    else:
      print("bm")
      return False
  
  def __get_benchmarks(self):
    resp = http_get('https://geocoding.geo.census.gov/geocoder/benchmarks')
    if resp.status_code == 200:
      self.benchmarks = [{"name":a['benchmarkName'],"id":int(a['id'])} for a in resp.json()['benchmarks']]
  
  def __get_query_string(self,query_dict):
    query_array = []
    
    if typeof(query_dict) == 'dict':
      for qsvar in [a for a in query_dict.keys()]:
        query_array.append("{}={}".format(qsvar,query_dict[qsvar]))
      
      return "&".join(query_array)
    else:
      return ""
  