########################################
# Typer - Wrapper for xdotool key stroke functionality
#
# Usage:
#
#   Create Typer instance
#
#      k = Typer()
#
#   Create Typer instance with custom X windows display name
#   
#      k = Typer(':1')
#
#   Send key strokes (up arrow twice)
#
#      k.SendKeys(['Up','Up'])
#
#   Send key strokes (Control-C)
#
#      k.SendKeys(['c'],['Control_L'])
#
#   Run command in the active terminal window (htop)
#
#      k.SendCommand('htop')
#
#   Retrieve list of valid keys
#
#      Typer.GetValidKeyCodes()
#
#      k.GetValidKeyCodes()
#
########################################


from os import system as run_cmd
from re import sub as regex_sub, match as regex_match
from requests import get as http_get

class Typer:
  """
  Usage:
    # Empty constructor uses ":0" X Windows display
    mytyper = Typer()
    
    # Optionally provide X Windows Display
    mytyper = Typer(":1")
  """
  def __init__(self,display=":0"):
    self.DISPLAY = display
    self.KEYS = self.GetValidKeyCodes()
  
  def SendKeys(self,keys=[],mods=[]):
    """
      # Send individual keystrokes in an array
      mytyper.SendKeys(['h','e','l','l','o'])
      
      # Send keystroke with modifier
      mytyper.SendKeys(['c'],['Control_L'])
    """
    if len(keys) > 0 and self.__validatekeys(keys):
      keystr = ' '.join(keys)
      
      modstart = ' '.join(["keydown {}".format(a) for a in mods])
      modend = ' '.join(["keyup {}".format(a) for a in mods])
      
      run_cmd("DISPLAY=\"{}\" xdotool {} key {} {}".format(self.DISPLAY,modstart,keystr,modend))
  
  
  
  def SendCommand(self,cmd_text):
    """
      # Run a command in the linux terminal
      mytyper.SendCommand('htop')
    """
    cmdar = [a for a in cmd_text]
    cmdar.append(Typer.KEY_ENTER)
    self.SendKeys(cmdar)
  
  def __validatekeys(self,k):
    """
      # Internal method used to validate an array of keystrokes
    """
    valid = [a for a in k if a in self.KEYS]
    
    return True if len(valid) == len(k) else False
  
  @staticmethod
  def GetValidKeyCodes():
    """
      # Static method Retreive list of valid keystrokes as defined by X Windows header files
      Typer.GetValidKeyCodes()
    """
    resp = http_get('https://cgit.freedesktop.org/xorg/proto/x11proto/plain/keysymdef.h')
    
    return [regex_sub(r'#define XK_([^ \t]+).*$','\\1',a) for a in resp.text.split('\n') if regex_match(r"#define XK_",a)]