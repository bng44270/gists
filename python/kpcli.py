#####################
# KeePass CLI
# 
# Return passwords, create, list, and delete groups and entries from KeePass database files
#####################

from pykeepass import PyKeePass
from arguments import Arguments
from getpass import getpass

ARGS = Arguments()

if not ARGS.IsArgs():
  print("usage:  kpcli.py -f <kp database> [-p <entry_name> | -d <entry|group> -v <name_or_title> | -g <new_group_name> | -e <new_entry_name> -g <group_name> -u <user_name> | -l <group|entry> ]")
else:
  if ARGS.Get('f'):
    kpfile = ARGS.Get('f')
    try:
      kp = PyKeePass(kpfile,password=getpass())
    except:
      kp = False
    
    if kp:
      if ARGS.Get('p'):
        entry_name = ARGS.Get('p')
        entry = kp.find_entries(title=entry_name,first=True)
        if entry:
          print(entry.password)
        else:
          print("Entry not found ({})".format(entry_name))
      elif ARGS.Get('l'):
        list_op = ARGS.Get('l')
        if list_op == 'entry':
          for entry in [a.title + ' (parent: ' + a.group.name + ')' for a in kp.entries]:
            print(entry)
        elif list_op == 'group':
          for group in [a.name for a in kp.groups]:
            print(group) 
        else:
          print("Invalid Operation (l)")
      elif ARGS.Get('d'):
        delete_op = ARGS.Get('d')
        
        if delete_op == 'entry':
          entry_name = ARGS.Get('v')
          entry = kp.find_entries(title=entry_name,first=True)
          if entry:
            try:
              kp.delete_entry(entry)
              print("Entry {} deleted".format(entry_name))
            except:
              print("Error deleting entry ({})".format(entry_name))
          else:
            print("Entry not found ({})".format(entry_name))
        elif delete_op == 'group':
          group_name = ARGS.Get('v')
          group = kp.find_groups(name=group_name,first=True)
          if group:
            try:
              kp.delete_group(group)
              print("Group {} deleted".format(group_name))
            except:
              print("Error deleting group ({})".format(group_name))
          else:
            print("Group not found ({})".format(group_name))
        else:
          print("Invalid Operation (d)")
      elif ARGS.Get('g'):
        group_name = ARGS.Get('g')
        group = kp.add_group(kp.root_group,group_name)
        if group:
          print("Created group {}".format(group_name))
        else:
          print("Error creating group ({})".format(group_name))
      elif ARGS.Get('e') and ARGS.Get('g') and ARGS.Get('u'):
        group_name = ARGS.Get('g')
        entry_name = ARGS.Get('e')
        user_name = ARGS.Get('u')
        password = getpass()
        group = kp.find_groups(name=group_name,first=True)
        if group:
          entry = kp.add_entry(group,entry_name,user_name,password)
          if entry:
            print("Created entry {}".format(entry_name))
          else:
            print("Error creating entry ({})".format(entry_name))
        else:
          print("Group not found ({})".format(group_name))
      else:
        print("Invalid operation")
    else:
      print("Error opening KeePass DB ({})".format(kpfile))
  else:
    print("KeePass DB not specified")