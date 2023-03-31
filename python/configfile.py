from re import sub as regex_sub
from os import path

class ConfigFile:
  """
    Usage:
    
      # Initialize object with no configuration file (must be configured with Read method)
      conf = ConfigFile()
      
      # Initialize object with a configuration file and read configuration
      conf = ConfigFile("/path/to/settings.conf")
      
    Configuration file format (uses key/value pairs):
    
      <KEY><space/tab><VALUE>
      # start lines with a hash to comment configuration file
    
  """
  def __init__(self,filename=""):    
    self.CONFIG = {}
    if len(filename) > 0:
      self.FILENAME = filename
      self.Read(filename)
  
  def Read(self,filename):
    """
      # Read data from configuration file
      conf.Read('/path/to/settings.conf')
    """
    if (path.exists(filename) or path.exists(self.FILENAME)) and (len(filename) > 0 or len(self.FILENAME) > 0):
      if filename and not self.FILENAME:
        self.FILENAME = filename
      with open(self.FILENAME,"r") as conffile:
        for line in conffile:
          if line[0] == '#' or len(line) == 0:
            continue
          else:
            self.CONFIG.update({regex_sub('^([^ \t]+).*$','\\1',str(line)).strip():regex_sub('^[^ \t]+[ \t]+(.*)$','\\1',str(line)).strip()})
  
  def IsNew(self):
    """
      # Returns True if the configuration object is empty, False if the object contains data
      is_new_file = conf.IsNew()
    """
    if self.CONFIG:
      return True
    else:
      return False
  
  def Write(self):
    """
      # Write data in configuration object to the file set in the constructor or Read function
      conf.Write()
    """
    with open(self.FILENAME,"w") as thisfile:
      for (k,v) in self.CONFIG.items():
        thisfile.write(k + "\t" + v + "\n")
  
  def Add(self,key,value):
    """
      # Add a new key/value pair to the configuration file (key = BINPATH, value = /usr/bin)
      conf.Add('BINPATH','/usr/bin')
    """
    if len(key) > 0 and len(value) > 0:
      self.CONFIG.update({key:value})
  
  def Get(self,key):
    """
      # Return the value of a provided key
      binary_file_path = conf.Get('BINPATH')
    """
    if self.CONFIG[key]:
      return self.CONFIG[key]
  
  def Remove(self,key):
    """
      # Remove an existing key from the object
      conf.Remove('BINPATH')
    """
    if self.CONFIG[key]:
      del self.CONFIG[key]