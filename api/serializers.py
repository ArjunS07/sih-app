from unittest.util import _MAX_LENGTH
from rest_framework import fields, serializers


from .models import Tutorship, Message, Meeting
from accounts.models import PlatformUser, School, Student, Tutor

from .choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES
"""

from myapp.models import MY_CHOICES, MY_CHOICES2

class MyModelSerializer(serializers.HyperlinkedModelSerializer):
    my_field = fields.MultipleChoiceField(choices=MY_CHOICES)
    my_field2 = fields.MultipleChoiceField(choices=MY_CHOICES2)

"""

class AccountSerializer(serializers.Serializer):
    pass

class PlatformUserSerializer(serializers.Serializer):
    name_id = serializers.CharField(max_length=128)
    language_medium = serializers.MultipleChoiceField(choices=LANGUAGE_MEDIUM_CHOICES)
    city = serializers.CharField(choices=CITY_CHOICES, max_length=32)

class SchoolSerializer(serializers.Serializer):
    account

class StudentSerializer(serializers.Serializer):
    subjects = fields.MultipleChoiceField(choices=SUBJECT_CHOICES)

    pass

class TutorSerializer(serializers.Serializer):
    pass

class TutorshipSerializer(serializers.Serializer):

    pass

class MessageSerializer(serializers.Serializer):
    pass

class MeetingSerializer(serializers.Serializer):
    pass