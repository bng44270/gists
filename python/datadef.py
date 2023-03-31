####################################
# > class Person(DataCache):
# ...  def __init__(self,file):
# ...    # Auto-cache JSON every 10 seconds
# ...    super().__init__(file,["first_name","last_name","age"],10)
# 
# > person = Person('/home/user/person.json')
# > person.Insert({"first_name":'Andy'})
# > person.Insert({"first_name":'Jim'})
# > person.Update(2,{'last_name':'Carlson'})
# > person.Query([('first_name','Andy')],return_fields=['first_name','age'])
# [{'first_name': 'Andy', 'age': ''}]
####################################

from json import dumps as dict2str, loads as str2dict
from threading import Timer
from os.path import exists
from re import match as regex_match

typeof = lambda v : type(v).__name__

class DataDef:
  """
    Usage:
    
      # Initialize empty dataset with fields
      mydata = DataDef(['name','age','email'])
      
      # Initialize dataset with custom data record(s)
      mydata = DataDef(['name','age','email'],[{'name':'Bob','age':12,'email':'bob123@hotmail.com','info':''}])
      
    Query syntax for the Query, Update, and Delete methods (denoted as <query-syntax>):
    
      [
        ["field","criteria"],
        ["field","criteria"],
        ...
      ]
      
      field - field name
      criteria - either a string literal or a regex string
  """
  def __init__(self,fields=[],data = []):
    self.FIELDS = fields
    self.PKEY = '_auto_'
    self.DATA = data
    self.FIELDS.append(self.PKEY)
    if len(self.DATA) == 0:
      self.KEY_AUTO = 1
    else:
      self.KEY_AUTO = sorted([a[self.PKEY] for a in self.DATA])[-1]
  
  def AddField(self,name=''):
    """
      # Add field to schema of dataset (adds field with empty value to existing records)
      mydata.AddField('address')
    """
    if len(name) > 0 and type in ['int','str']:
      self.FIELDS.append(name)
      for row in self.DATA:
        row[name] = ''
  
  def Insert(self,row={}):
    """
      # Insert new row into dataset
      mydata.Insert({'name':'Joe','age':23,'email':'joe5@gmail.com','address':'123 street'})
    """
    newKey = -1
    if len([a for a in row.keys() if a in self.FIELDS])  == len(row.keys()):
      if not self.PKEY in row.keys():
        newKey = self.KEY_AUTO
        row[self.PKEY] = self.KEY_AUTO
        self.KEY_AUTO = self.KEY_AUTO + 1
      extra = [a for a in self.FIELDS if not a in row.keys()]
      for blank_field in extra:
        row[blank_field] = ''
      self.DATA.append(row)
    return newKey
  
  def Delete(self,q):
    """
      # Delete records from dataset matching <query-syntax>
      mydata.Delete(<query-syntax>)
    """
    self.DATA = [a for a in self.DATA if False in [regex_match(b[1],str(a[b[0]])) or False for b in q]]
  
  def Update(self,q,row={}):
    """
      # Update records in dataset matching <query-syntax>
      # <query-syntax> is the first argument
      # The second argument is a dictionary.  The keys are the field names and the values are the new field values
      
      mydata.Update([['email',r'^.*gmail.com$']],{'info':'This is a GMAIL user'})
    """
    ids = self.Query(q,return_fields=[self.PKEY])
    
    for update_id in ids:
      prev = [a for a in self.DATA if a[self.PKEY] == update_id][0]
      for key in row.keys():
        prev[key] = row[key]
      self.Delete([[self.PKEY,update_id]])
      self.Insert(prev)
  
  def Query(self,q,return_fields=[],sort_field='_auto_',decending = False):
    """
      # Query dataset for records matching <query-syntax>
      # Uses <query-syntax> as the first argument
      mydata.Query([['name','Bob']])
      
      # Query dataset returning certain fields
      mydata.Query(['name','Bob'],['address'])
      
      # Query dataset sorting data by a field (default sort field is the auto id) in decending order
      mydta.Query(['name','Bob'],sort_field='name',decending = True)
    """
    if len(return_fields) == 0:
      return_fields = self.FIELDS
    result = [{k:a[k] for k in list(a.keys()) and return_fields} for a in self.DATA if not False in [regex_match(b[1],str(a[b[0]])) or False for b in q]]
    return sorted(result, key = lambda x : x[sort_field], reverse = decending)

class DataCache(DataDef):
  """
    Usage:
    
      # Initialize dataset from JSON file
      # NOTE:  DataCache requiring identical fields on each record to accurately detect schema
      mydata = DataCache('/path/to/people.json')
      
      # Initialize dataset from JSON file configuring automatic writes to the file every 10 seconds
      mydata = DataCache('/path/to/people.json',10)
      
      
    Query syntax for the Query, Update, and Delete methods (denoted as <query-syntax>):
    
      [
        ["field","criteria"],
        ["field","criteria"],
        ...
      ]
      
      field - field name
      criteria - either a string literal or a regex string
  """
  def __init__(self,file,cachetime=0):
    self.FILE = file
    
    if not exists(file):
      with open(file,'w') as f:
        f.write('[]')
    
    data = str2dict(self.___read_cache())
    
    fields = self.__detect_schema(data)
    
    if typeof(fields) == 'list':
      super().__init__(fields,data)
      
      if (cachetime == 0):
        self.AUTO_CACHE = False
      else:
        self.AUTO_CACHE = True
        self.CACHE_TIME = cachetime
        Timer(self.CACHE_TIME,self.Cache).start()
    else:
      raise Exception('Schema mismatch in {} on record {}'.format(file,str(fields + 1)))
  
  def Insert(self,row={}):
    """
      # Insert a single row of data.
      mydata.Insert({'name':'Joe','age':23,'email':'joe5@gmail.com','address':'123 street'})
    """
    super().Insert(row)
    if not self.AUTO_CACHE:
      self.Cache()
  
  def Delete(self,q):
    """
      # Delete records from dataset matching <query-syntax>
      mydata.Delete(<query-syntax>)
    """
    super().Delete(q)
    if not self.AUTO_CACHE:
      self.Cache()
  
  def Update(self,q,row={}):
    """
      # Update records in dataset matching <query-syntax>
      # <query-syntax> is the first argument
      # The second argument is a dictionary.  The keys are the field names and the values are the new field values
      
      mydata.Update([['email',r'^.*gmail.com$']],{'info':'This is a GMAIL user'})
    """
    super().Update(id,row)
    if not self.AUTO_CACHE:
      self.Cache()
  
  def Query(self,q,return_fields=[],sort_field='_auto_',decending = False):
    """
      # Query dataset for records matching <query-syntax>
      # Uses <query-syntax> as the first argument
      mydata.Query([['name','Bob']])
      
      # Query dataset returning certain fields
      mydata.Query(['name','Bob'],['address'])
      
      # Query dataset sorting data by a field (default sort field is the auto id) in decending order
      mydta.Query(['name','Bob'],sort_field='name',decending = True)
    """
    super().Query(q,return_fields,sort_field,decending)
  
  def Cache(self):
    """
      # Manually cache data to JSON file named in the construtor
      mydata.Cache()
      
      # If seconds are provided when DataCache is instantiated this function is called automatically
    """
    filecontent = self.___read_cache()
    datastring = dict2str(self.DATA)
    if not filecontent == datastring:
      with open(self.FILE,"w") as f:
        f.write(datastring)
    
    if self.AUTO_CACHE:
      Timer(self.CACHE_TIME,self.Cache).start()
  
  def __detect_schema(self,data):
    badrecord = -1
    
    schema = sorted(list(data[0].keys()))
    
    for i in range(1,len(data)-1):
      if not sorted(list(data[i].keys())) == schema:
        badrecord = i
        break
    
    return schema if badrecord == -1 else badrecord
  
  def __read_cache(self):
    with open(self.FILE,'r') as f:
      return str(''.join(f.readlines()))
