########################################
# linksys_jnap.py
#
# Call JNAP API endpoints on Linksys Routers
#
# Tested with WRT3200ACM
#
# Available Actions:
#
#    ## Name ##                    ## Action URL ##
#    GetDeviceInfo                 http://cisco.com/jnap/core/GetDeviceInfo
#    GetRemoteSetting              http://linksys.com/jnap/ui/GetRemoteSetting
#    CheckAdminPassword            http://linksys.com/jnap/core/CheckAdminPassword
#    GetWANSettings2               http://linksys.com/jnap/router/GetWANSettings2
#    GetWirelessSchedulerSettings  http://linksys.com/jnap/wirelessscheduler/GetWirelessSchedulerSettings
#    GetGuestRadioSettings         http://linksys.com/jnap/guestnetwork/GetGuestRadioSettings
#    GetWANStatus3                 http://linksys.com/jnap/router/GetWANStatus3
#    GetRadioInfo3                 http://linksys.com/jnap/wirelessap/GetRadioInfo3
#    GetParentalControlSettings    http://linksys.com/jnap/parentalcontrol/GetParentalControlSettings
#    GetPartitions                 http://linksys.com/jnap/storage/GetPartitions
#    GetFirmwareUpdateStatus       http://linksys.com/jnap/firmwareupdate/GetFirmwareUpdateStatus
#    UpdateFirmwareNow             http://linksys.com/jnap/firmwareupdate/UpdateFirmwareNow
#
# Usage:
#
#    # Use OOB admin password
#    fw = LinksysJnap('192.168.1.1')
#    # OR Use custom admin password
#    fw = LinksysJnap('192.168.1.1','pass1234')
#    # device_info will contain <dict> of JSON response
#    device_info = fw.RunAction('GetDeviceInfo')
#
########################################

from requests import request as http_request
from base64 import b64encode
from urllib.parse import quote as urlencode

class LinksysJnap:
  def __init__(self,addr,adminpass='admin'):
    self.addr = addr
    self.authheader = self.__buildauth(adminpass)
    self.actions = [{'url': 'http://cisco.com/jnap/core/GetDeviceInfo', 'post': '{}', 'name': 'GetDeviceInfo'}, {'url': 'http://linksys.com/jnap/ui/GetRemoteSetting', 'post': '{}', 'name': 'GetRemoteSetting'}, {'url': 'http://linksys.com/jnap/core/CheckAdminPassword', 'post': '{}', 'name': 'CheckAdminPassword'}, {'url': 'http://linksys.com/jnap/router/GetWANSettings2', 'post': '{}', 'name': 'GetWANSettings2'}, {'url': 'http://linksys.com/jnap/wirelessscheduler/GetWirelessSchedulerSettings', 'post': '{}', 'name': 'GetWirelessSchedulerSettings'}, {'url': 'http://linksys.com/jnap/guestnetwork/GetGuestRadioSettings', 'post': '{}', 'name': 'GetGuestRadioSettings'}, {'url': 'http://linksys.com/jnap/router/GetWANStatus3', 'post': '{}', 'name': 'GetWANStatus3'}, {'url': 'http://linksys.com/jnap/wirelessap/GetRadioInfo3', 'post': '{}', 'name': 'GetRadioInfo3'}, {'url': 'http://linksys.com/jnap/parentalcontrol/GetParentalControlSettings', 'post': '{}', 'name': 'GetParentalControlSettings'}, {'url': 'http://linksys.com/jnap/storage/GetPartitions', 'post': '{}', 'name': 'GetPartitions'}, {'url': 'http://linksys.com/jnap/firmwareupdate/GetFirmwareUpdateStatus', 'post': '{}', 'name': 'GetFirmwareUpdateStatus'}, {'url': 'http://linksys.com/jnap/firmwareupdate/UpdateFirmwareNow', 'post': '{"onlyCheck":true}', 'name': 'UpdateFirmwareNow'}]
  
  def RunAction(self,action):
    if action in [a['name'] for a in self.actions]:
      headers = {}
      headers[self.authheader[0]] = self.authheader[1]
      headers['Cookie'] = 'visited-index=true; is_cookies_enabled=null; admin-auth=' + urlencode(self.authheader[1])
      headers['Accept'] = '*/*'
      headers['Accept-Language'] = 'en-US,en;q=0.5'
      headers['Accept-Encoding'] = 'gzip, deflate'
      headers['Content-Type'] = 'application/json; charset=UTF-8'
      headers['Cache-Control'] = 'no-cache'
      headers['Connection'] = 'keep-alive'
      
      headers['X-JNAP-Action'] = [a['url'] for a in self.actions if a['name'] == action][0]
      resp = http_request('POST', 'http://' + self.addr + '/JNAP/', headers = headers, data = bytes([a['post'] for a in self.actions if a['url'] == action][0],'utf-8'))
      
      if resp.status_code == 200:
        return resp.json()
      else:
        return {'result':'http error'}
    
    else:
      return {'result':'invalid service'}
  
  def __buildauth(self,passwd):
    encoded = b64encode(bytes('admin:' + passwd,'utf-8'))
    header = ['X-JNAP-Authorization','Basic ' + str(encoded,'utf-8')]
    return header