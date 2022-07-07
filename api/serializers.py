"""
from rest_framework import fields, serializers

from myapp.models import MY_CHOICES, MY_CHOICES2

class MyModelSerializer(serializers.HyperlinkedModelSerializer):
    my_field = fields.MultipleChoiceField(choices=MY_CHOICES)
    my_field2 = fields.MultipleChoiceField(choices=MY_CHOICES2)

"""