# Tested wtih Foscam Fi8910w camera

from os import listdir, remove as remove_file
from re import match as regex_match, sub as regex_sub
from random import random as gen_random
import requests


class Foscam:
  def __init__(self, cachedir='/tmp', host='', user='', passwd=''):
    self.CAMS = {}
    self.cachedir = cachedir
    
    self.__clearcache()
    
    if not(len(host) == len(user) == len(passwd) == 0):
      self.AddCamera(host,user,passwd)
  
  def AddCamera(self,host,user,passwd):
    template = 'http://{}/snapshot.cgi?user={}&pwd={}&count=1'
    self.CAMS[host] = template.format(host,user,passwd)
  
  def ListCameras(self):
    return [a for a in self.CAMS]
  
  def Capture(self,host):
    hostvalid = [a for a in self.CAMS if a == host]
    
    if len(hostvalid) > 0:
      imgfile = self.__gettempfile()
      
      resp = requests.get(self.CAMS[host])
      
      if resp.status_code == 200:
        with open(imgfile,'wb') as f:
          f.write(resp.content)
      
      return imgfile
  
  def __clearcache(self):
    imagefiles = [a for a in listdir(self.cachedir) if regex_match(r'^foscam-',a)]
    
    for thisfile in imagefiles:
      remove_file(self.cachedir + '/' + thisfile);
      
  def __gettempfile(self):
    return '{}/foscam-{}.jpg'.format(self.cachedir,regex_sub(r'^0\.0*','',str(gen_random()))[:5])