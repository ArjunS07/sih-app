import requests
import jwt
import json
import os
import time

ZOOM_API_KEY = os.getenv('ZOOM_API_KEY')
ZOOM_API_SECRET = os.getenv('ZOOM_API_SECRET')

def generate_jwt_token():
    token = jwt.encode(
        # Create a payload of the token containing API Key & expiration time
        {'iss': ZOOM_API_KEY, 'exp': time.time() + 5000},
        # Secret used to generate token signature
        ZOOM_API_SECRET,
        # Specify the hashing alg
        algorithm='HS256'
        # Convert token to utf-8
    )
    return token
    # send a request with headers including a token

# TODO: limited to 100 requests
url = "https://api.zoom.us/v2/users/me/meetings"

def generate_zoom_meeting(student_name, tutor_name):

    payload = json.dumps({
    "topic": "Volunteer tutor meeting",
    "type": 3,
    "timezone": "Asia/Kolkata",
    "agenda": f"Meeting for {tutor_name} and {student_name} ", #TODO
    "settings": {
        "host_video": "true",
        "participant_video": "true",
        "join_before_host": "true",
    }
    })
    headers = {
    'authorization': f'Bearer {generate_jwt_token()}',
    'Content-Type': 'application/json',
    }
    
    response = requests.request("POST", url, headers=headers, data=payload)
    data = json.loads(response.text)
    return {
        "meeting_id": data['id'],
        "meeting_password": data['password'],
        "meeting_encrypted_password": data['encrypted_password'],
        "start_url": data['start_url'],
        "join_url": data['join_url'],
    }