from rest_framework import serializers

from . import models

class TutorSerializer(serializers.Serializer):
    account_id = serializers.PrimaryKeyRelatedField(read_only=True)
    name_id = serializers.CharField(max_length=128)
    city = serializers.CharField(max_length=8)
    languages = serializers.ListField(child=serializers.CharField(max_length=1024))
    boards = serializers.ListField(child=serializers.CharField(max_length=128))
    subjects = serializers.ListField(child=serializers.CharField(max_length=1024))
    grades = serializers.ListField(child=serializers.CharField(max_length=128))

    class Meta:
        model = models.Tutor
        fields = ('account', 'name_id', 'city', 'languages', 'boards', 'subjects', 'grades')

class StudentSerializer(serializers.Serializer):
    account_id = serializers.PrimaryKeyRelatedField(read_only=True)
    name_id = serializers.CharField(max_length=128)
    city = serializers.CharField(max_length=8)
    languages = serializers.ListField(child=serializers.CharField(max_length=1024))
    board = serializers.CharField(max_length=8)
    # subjects = serializers.ListField(child=serializers.CharField(max_length=1024))
    grade = serializers.CharField(max_length=8)
    class Meta:
        model = models.Student
        fields = ('account', 'name_id', 'city', 'languages', 'board', 'grade')

class ZoomMeetingSerializer(serializers.Serializer):
    link = serializers.CharField(max_length=1024)
    meeting_id = serializers.CharField(max_length=32)
    meeting_password = serializers.CharField(max_length=1024)
    num_occurences = serializers.IntegerField()

    class Meta:
        model = models.ZoomMeeting
        fields = ('link', 'meeting_id', 'meeting_password', 'num_occurences')

class TutorshipSerializer(serializers.Serializer):
    tutor_id = serializers.CharField(source='tutor.name_id', read_only=True)
    student_id = serializers.CharField(source='student.name_id', read_only=True)
    status = serializers.CharField(max_length=8)
    zoom_meeting_id = serializers.CharField(source='zoom_meeting.meeting_id', read_only=True)

    class Meta:
        model = models.Tutorship
        fields = ('tutor_name_id', 'student_name_id', 'status', 'zoom_meeting_meeting_id')

class MessageSerializer(serializers.Serializer):
    text = serializers.CharField()
    timestamp = serializers.DateTimeField(read_only=True)
    
    tutorship_id = serializers.CharField(max_length=32)
    sent_by_student = serializers.BooleanField()
    # sender_id = serializers.CharField(read_only=True, max_length=32, source='sender.name_id')

    # has_attachment = serializers.BooleanField(default=False)
    attachments_folder_prefix = serializers.CharField(max_length=1024, default=None)

    class Meta:
        model = models.Message
        fields = ('text', 'timestamp', 'sent_by_student', 'tutorship_id', 'sender_id','attachments_folder_prefix')

    def create(self, validated_data):
        return models.Message.objects.create(**validated_data)