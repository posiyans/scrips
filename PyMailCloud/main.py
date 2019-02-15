import json
#import gnupg
import os
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


from PyMailCloud import PyMailCloud
from PyMailCloud import PyMailCloudError



mail_cloud = PyMailCloud("123@mail.ru", "123123) # do not change the password please :)
mail_cloud.download_folder_content('/')

