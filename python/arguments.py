from re import sub as regex_sub
from sys import argv as arglist

class Arguments:
  """
    Usage:
    
      # Initialize to read in command arguments
      args = Arguments()
  """
  def __init__(self):
    self.ARGS = {}
    idx = 0
    while idx < len(arglist):
      if arglist[idx].startswith('-'):
        try:
          if arglist[idx+1].startswith('-'):
            self.ARGS[regex_sub("^-","",arglist[idx])] = True
            idx += 1
          else:
            self.ARGS[regex_sub("^-","",arglist[idx])] = arglist[idx+1]
            idx += 2
        except:
          self.ARGS[regex_sub("^-","",arglist[idx])] = True
          idx += 1
      else:
        idx += 1
        continue
  
  def IsArgs(self):
    """
      # Returns True if arguments are provided and False if no arguments are provided
      arguments_exist = args.IsArgs()
    """
    return True if self.ARGS else False
		
  def Get(self,arg):
    """
      # Return the value of the argument (if an argument exists with no value boolean True is returned)
      arg_value = args.Get('b')
      
      # Boolean False is returned if the argument does not exist
    """
    try:
      return self.ARGS[arg]
    except:
      return False