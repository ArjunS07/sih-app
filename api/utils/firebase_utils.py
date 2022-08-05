import json
import os

import pyrebase

base_path = os.getcwd()
config_path = os.path.join(base_path, '/firebase_config.json')
config = json.loads(open(config_path).read())
firebase = pyrebase.initialize_app(config)
storage = firebase.storage()