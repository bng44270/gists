import requests
import re

def GetGistList(username,suffix = ''):
  gistar = []
  
  req = requests.get('https://api.github.com/users/{}/gists{}'.format(username,suffix))
  gistar.extend([{'description':b['description'],'file':list(b['files'].keys())[0],'url':b['url']} for b in req.json()])
  linkhead = [a for a in req.headers['Link'].split(', ') if '"next"' in a]
  
  if len(linkhead) == 1:
    suffix = re.sub(r'^<[^?]+([^>]+)>.*$',r'\1',linkhead[0])
    gistar.extend(GetGistList(username,suffix))
  
  return gistar
  
def GetRepoList(username,suffix = ''):
  repoar = []
  
  req = requests.get('https://api.github.com/users/{}/repos{}'.format(username,suffix))
  repoar.extend([{'name':b['name'],'description':b['description'],'url':b['url']} for b in req.json()])
  linkhead = [a for a in req.headers['link'].split(', ') if '"next"' in a]
  
  if len(linkhead) == 1:
    suffix = re.sub(r'^<[^?]+([^>]+)>.*$',r'\1',linkhead[0])
    repoar.extend(GetRepoList(username,suffix))
  
  return repoar