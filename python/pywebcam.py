# Requires Linux with fswebcam (tested on Debian 9)

# Usage:
#  > cam = PyWebCam()
#  > cam.GetCams()
#  ['video0','video1']
#  > cam.Capture('video0')
#  '/tmp/pycam-12345.jpg'
#  > cam.Capture('video0','/root/images')
#  '/root/images/pycam-87654.jpg'

from os import system as run_cmd, listdir, remove as remove_file
from re import match as regex_match, sub as regex_sub
from random import random as gen_random

class PyWebCam:
  """
    Usage:
    
      # Initialize PyWebCam with default settings
      cam = PyWebCam()
      
      # Initialize PyWebCam to search for entries in /dev with "vid" or "pic" prefix
      cam = PyWebCam(['vid','pic'])
      
      # Initialize PyWebCam to cache pictures in /data/pics
      cam = PyWebCam(cachedir='/data/pics')
  """
  def __init__(self,devices=['video'],cachedir='/tmp'):
    self.cachedir = cachedir
    self.CAMS = []
    
    for f in listdir('/dev'):
      if (regex_match(r'^(' + '|'.join(devices) + ')',f)):
        self.CAMS.append(f)
    
    self.__clearcache()
  
  def GetCams(self):
    """
      # Return a list of detected cameras
      cam.GetCams()
    """
    return self.CAMS
  
  def Capture(self,dev):
    """
      # Capture a picture from device "video0"
      imgfile = cam.Capture('video0')
      
      # imgfile will contain the full path to the image file
    """
    returnvalue = ''
    
    if (dev in self.CAMS):
      tempfile = self.__gettempfile()
      results = run_cmd('fswebcam -d /dev/{} -q {}'.format(dev,tempfile))
      if (results == 0):
        returnvalue = tempfile
    
    return returnvalue
  
  def __clearcache(self):
    imagefiles = [a for a in listdir(self.cachedir) if regex_match(r'^pycam-',a)]
    
    for thisfile in imagefiles:
      remove_file(self.cachedir + '/' + thisfile);
  
  def __gettempfile(self):
    return '{}/pycam-{}.jpg'.format(self.cachedir,regex_sub(r'^0\.0*','',str(gen_random()))[:5])
