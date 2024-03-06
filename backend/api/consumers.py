from channels.generic.websocket import WebsocketConsumer
import json
from rest_framework.renderers import JSONRenderer


from . import models, serializers

class WSConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()
        self.send(json.dumps({
            'connection_status': 'connected'
        }))
    
    def receive(self, text_data=None, bytes_data=None):
        text_data_json = json.loads(text_data)
        text = text_data_json['text']
        tutorship_id = text_data_json['tutorship_id']
        sender_uuid = text_data_json['sender_uuid']
        uuid = text_data_json['uuid']

        data = {
            'tutorship__id': tutorship_id,
            'text': text,
            'sender_uuid': sender_uuid,
            'uuid': uuid
        }
        serializer = serializers.MessageSerializer(data=data)
        if serializer.is_valid():
            print(serializer.validated_data)
            serializer.save()
            print('Rendered json', serializer.data)
            self.send(json.dumps({'message': serializer.data}))
        else:
            print(serializer.errors)
            self.send(json.dumps({
                'message': serializer.errors
            }))