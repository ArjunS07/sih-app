import os
import json

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def get_tutorship_messages_data(tutorship_id):
    id_str = str(tutorship_id)
    docs = messages_ref.where(u'tutorship_id', u'==', tutorship_id).stream()
    return docs

current_path = os.getcwd()
json_path = os.path.join(current_path, 'core/utils/volunteertutoring-37dfa-5436961a05d9.json')
service_account_creds = json.load(open(json_path))
service_account_creds["private_key"] = "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC3SPR/Ho1hTJUV\nQTIA1IB87itkpNUoLCg01DXjbzM/m+n9QXtQpmJy3pILgQT+o7EepaY0o753PlCq\nwy/XQ/IS9EbuuffF6F3h4qmPnTPD3lmR8CJw9DGWl04HAHLjxa0yS7KaHJu6GOUu\nDlik6NqFuOFqwox5ADz/vvKNbcWA2aEWBR6NGNx/ivF94iLkgo9K8EbiPtH2VqX/\nWJJEI0Jw9gBeFvBxXmtBLnZpdPgrsD/YqtOQMOGuF++xpJlQVkBYA+b6qpVTxiyW\nLb1dqNmfcMSuwrH0r18fOuZHx5FfWVNiFV0fO6ChU1Bb7OZtH/mmzKFfCjNgoVbA\nb0drtYH1AgMBAAECggEAGoqvkVsIyT7QVggfaBxd0PmiggwWrB8c4W2bsihPyRXY\ngCrD40188zqE9rKD2SY2R4Rgeb3+noEBKIFkg61cuF70iKyYk2nPcp8iw9/Vd7dS\nzD30ltvd9HtLutrXSGG/b4mjvwqGiKADTDSapKLtxjCcQBwVQI6GxthNgqqTT9G1\nUt1CVCRT48fsWjtei2CnXfsTWoSNlUrUWs5UkvLxANItvIxQYn8Hw85/zw5zYM6W\ndn5yeAkUOoTf/0kCw0ZGEmmROSht/FHDAh89tVg8uB6wHzAzfHHVqlx+uOzKGdcY\n69IntekC193G3VJdu21Ifhy20JzMy2Fe15SD/Z4xsQKBgQDm+lkrHFUigfW+iAW8\nCIQP8t/T5Hm8gzEgfJEgmh3M5xxkjiRUG4ClICRfAncxb6q0+YhsgFpzdphUu4c9\n9sPTw7HsPwyBvB4PbkuFNL8V7T8PZr/lIDGfBJt20icQ3mJjoYf7fMxPP3mc673p\n0HF+pDhfBtw6slAlOBl33sTO6QKBgQDLI/NYySe/HN1WncUu07UpPP8+eD/XX1z9\nhBv8HaxkIgjMd8fbsJVTygpACaO82tqvutfD/SuKe7a6GVRXvboKRDBu5E3dTMF5\nc57zLyHXpb9+A6LA1gUlKHhEMd35zcuwijzEiL/Q5Kw3SUDbFqi8tXsbiHXmqD5V\nGXzr7/wrLQKBgQCJtyyhMqRkDb6a2nko0p8C71ma+ffHeSU6bGsPWDR6bjWUkteA\nOmGqko59A3hTxnOusbUwlBraCxTqOGF7hXze7yhPZowrciEuLCHlCzz/ctQNd8Lk\ndxx+5n1XDBf0y9M3+iCcxpz+hycYc8po9TomOv3NUsbOTHDSsC8nNHB9uQKBgQCo\n/edbXTxriJ+5htaa9hQnkk7ksTSq/vJlFJoTSrw3MPkQ4DSrVmNjqRiN3XcRjR+Q\nQWdt7BdkxTZl6tx3gaZbFA8WsWb1Sv1JBB6fP/5vX7vGIVAsC9+L4fbrBHEdd06U\nNuwGs5yfMxzxgUcq+9az5mXbqdIraJsyQFnkDWlCoQKBgQCmlsnh5XZPnM2HZ0Fl\nxBBwcss3EBqUID5JJbTITsiIXvI/1A7o9jRSLfA7up3ykYV98L/UzDF06vUXPyaF\n94NB7YKynPQTyn0hDqEHg1R/brFHWz+4b2MU+4+7Oiq1zsqbrZVu8xqsBl/oOcpw\n2TDZhLKqlTIn87YDA50Rdi/fKg==\n-----END PRIVATE KEY-----\n"

cert = credentials.Certificate(service_account_creds)
firebase_admin.initialize_app(cert)
db = firestore.client()

messages_ref = db.collection(u'messages')

def get_tutorship_message_log(tutorship):
    tutorship_id = tutorship.id
    tutorship_tutor = tutorship.tutor
    tutor_uuid = tutorship_tutor.uuid
    tutor_name = tutorship_tutor.name
    tutorship_student = tutorship.student
    student_uuid = tutorship_student.uuid
    student_name = tutorship_student.name
    
    messages = get_tutorship_messages_data(tutorship_id)
    
    log_str = ""
    for message in messages:
        data = message.to_dict()
        message_type = data['type']
        if message_type == 'text':
            text_content = data['text_content']
            time_sent = data['time_sent'].strftime("%m/%d/%Y, %H:%M:%S")
            sender_uuid = data['sender_uuid']
            sender_name = ""
            if sender_uuid == tutor_uuid:
                sender_name = tutor_name
            elif sender_uuid == student_uuid:
                sender_name = student_name
            message_log = f'{sender_name} at {time_sent}: {text_content}'
            log_str += message_log
            log_str += '\n'
    
    return log_str