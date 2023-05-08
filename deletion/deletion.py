from __future__ import print_function
from importlib.resources import Resource
import pygsheets
from google.oauth2 import service_account
import json
from datetime import *
import datetime
import os

# opening & authnetication of google sheet
with open('python-delete-42f8aae80dcc.json') as source:
    info = json.load(source)
credentials = service_account.Credentials.from_service_account_info(info)
client = pygsheets.authorize(service_account_file='python-delete-42f8aae80dcc.json')
sheet = client.open_by_key('1oeOxeUvPftRFdVDVVfgW1ABD7Xp-I95OPG0J-1iUXTU')
wks = sheet.worksheet_by_title('test')
all_values = wks.get_all_values()

#date
date=datetime.datetime.today().strftime('%m/%d/%Y')

#getting required columns
fifth_column = wks.get_col(5)
fifth_list = [i for i in fifth_column if i]
fifth_list.remove('Required till (mm/dd/yyyy)')

first_column = wks.get_col(1)
first_list = [i for i in first_column if i]
first_list.remove('Resource Details')

second_column = wks.get_col(2)
second_list = [i for i in second_column if i]
second_list.remove('Azure Resource Group')

#function performing deletion on the basis of rg_name 
def delete(rg_name):
 exit_status=os.system(f' az group delete -n {rg_name} -y')
 if(exit_status==0):
    print("Deleted RG"+" --> "+ rg_name)
 else:
    print("Command fail to execute with exit status -> %d" % exit_status)

  
# vmname= corresponding VM name
# vm_date= corresponding required till vm date
for (vm_name,rg_name,vm_date) in zip(first_list,second_list,fifth_list):
    if(date>vm_date):
        delete(rg_name)
    else:
        print("Resource group --->"+ rg_name + " is in required limits ")



