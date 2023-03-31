import requests

class PyIFTTT:
  """
    Usage:
    
      # Initialize object with IFTTT API Key
      myifttt = PyIFTTT('api-key')
  """
  def __init__(self,key=""):
    if len(key) > 0:
      self.KEY = key
    else:
      raise ValueError('IFTTT Webhook key not provided')
  
  def Send(endpoint_id,valueOne, valueTwo="", valueThree=""):
    """
      # Send Webhook Request using webhook name and a single value
      myifttt.Send("tweekhook","value-1-text")
      
      # Send a Webhook Request using webhook name and either 2 or 3 values
      myifttt.Send("tweethook","value-1-text","value-2-text","value-3-text")
    """
    postObj = { "Value1" : valueOne, "Value2":valueTwo, "Value3" : valueThree }
    postUrl = "https://maker.ifttt.com/trigger/{{{}}}/with/key/{}".format(endpoint_id,self.KEY)
    resp = requests.post(postUrl, json = postObj)
    return True if resp.status_code == 200 else False