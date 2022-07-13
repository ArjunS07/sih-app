from rest_framework import serializers

from . import models

class TutorSerializer(serializers.Serializer):
    account = serializers.PrimaryKeyRelatedField(read_only=True)
    name_id = serializers.CharField(max_length=128)
    city = serializers.CharField(max_length=8)
    languages = serializers.ListField(child=serializers.CharField(max_length=1024))
    boards = serializers.ListField(child=serializers.CharField(max_length=128))
    subjects = serializers.ListField(child=serializers.CharField(max_length=1024))
    grades = serializers.ListField(child=serializers.CharField(max_length=128))

    class Meta:
        model = models.Tutor
        # fields = ('account', 'name_id', 'city', 'languages', 'boards', 'subjects', 'grades')
        fields = ('account', 'name_id', 'city', 'languages', 'boards', 'subjects', 'grades')