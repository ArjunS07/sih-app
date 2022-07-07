from tracemalloc import start
import requests
import json
from time import time
import datetime

import jwt

ZOOM_API_KEY = 'asaLyopgREOsrFaFDxG2nw'
ZOOM_API_SECRET = 'D5To4y6ztyHjJE6Ihd8mnJPTG8a49F2n6eg0'


def generate_jwt_token() -> str:
    token = jwt.encode(
        # Create a payload of the token containing the API Key & expiration time
        {'iss': ZOOM_API_KEY, 'exp': time() + 5000},
        ZOOM_API_SECRET,  # Secret used to generate token signature
        algorithm='HS256'
    )

    return token.decode('utf-8')

def format_datetime(date) -> str:
    return date.strftime("%Y-%m-%dT%H:%M:%SZ")

def create_meeting(title: str, minutes_duration: int, start_time: datetime.datetime, timezone: str, emails: list[str]) -> dict:

    formatted_emails = '; '.join(emails)
    formatted_start_time = format_datetime(start_time)

    meetingdetails = {
        "topic": title,
        "type": "1",
        # "start_time": formatted_start_time,
        "duration": str(minutes_duration),
        # "timezone": timezone,
        "settings": {
            "participant_video": "true",
            "join_before_host": "true",
            "watermark": "False",
            "auto_recording": "cloud",
            'alternative_hosts': formatted_emails
        }
    }

    res = {}
    join_url = res['join_url']
    password = res['password']
    return res