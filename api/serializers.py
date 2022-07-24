from email.policy import default
from wsgiref import validate
from rest_framework import serializers

from . import models
from accounts import models as accounts_models

class PlatformUserSerializer(serializers.ModelSerializer):
    account__id = serializers.IntegerField(source='account.id')
    uuid = serializers.UUIDField()
    city = serializers.CharField(max_length=8)
    languages = serializers.ListField(
        child=serializers.CharField(max_length=12))
    profile_image_s3_path = serializers.CharField(read_only=True, max_length=255)
    
    class Meta:
        model = accounts_models.PlatformUser
        fields = ('account__id', 'uuid', 'city', 'languages', 'profile_image_s3_path')
        abstract = True

class TutorSerializer(PlatformUserSerializer):

    boards = serializers.ListField(child=serializers.CharField(max_length=128))
    subjects = serializers.ListField(
        child=serializers.CharField(max_length=1024))
    grades = serializers.ListField(child=serializers.CharField(max_length=128))

    class Meta:
        model = models.Tutor
        fields = ('account__id', 'uuid', 'city', 'languages', 'profile_image_s3_path',
                  'boards', 'subjects', 'grades')

    def create(self, validated_data):
        account_id = int(validated_data['account']['id'])
        account = accounts_models.User.objects.get(id=account_id)
        print(account)
        del validated_data['account']

        if not account:
            raise serializers.ValidationError("Account not found")

        if len(models.Student.objects.filter(account=account)) > 0 or len(models.Tutor.objects.filter(account=account)) > 0:
            raise serializers.ValidationError("Platform user linked to given account already exists")
        
        return models.Tutor.objects.create(account=account, **validated_data)


class StudentSerializer(PlatformUserSerializer):

    board = serializers.CharField(max_length=8)
    grade = serializers.CharField(max_length=8)

    class Meta:
        model = models.Student
        fields = ('uuid', 'account__id', 'city', 'languages', 'profile_image_s3_path', 
        'board', 'grade')

    def create(self, validated_data):
        account_id = int(validated_data['account']['id'])
        account = accounts_models.User.objects.get(id=account_id)
        print(validated_data)
        del validated_data['account']

        if not account:
            raise serializers.ValidationError("Account not found")

        if len(models.Student.objects.filter(account=account)) > 0 or len(models.Tutor.objects.filter(account=account)) > 0:
            raise serializers.ValidationError("Platform user linked to given account already exists")
        
        return models.Student.objects.create(account=account, **validated_data)

class SchoolSerializer(serializers.Serializer):
    account__id = serializers.IntegerField(source='account.id')
    name = serializers.CharField(max_length=128)
    city = serializers.CharField(max_length=8)
    join_code = serializers.CharField(max_length=10)

    class Meta:
        model = models.School
        fields = ('account__id', 'name', 'city', 'join_code')


class ZoomMeetingSerializer(serializers.Serializer):
    link = serializers.CharField(max_length=1024)
    meeting_id = serializers.CharField(max_length=32)
    meeting_password = serializers.CharField(max_length=1024)
    num_occurences = serializers.IntegerField()

    class Meta:
        model = models.ZoomMeeting
        fields = ('link', 'meeting_id', 'meeting_password', 'num_occurences')

    def create(self, validated_data):
        return models.ZoomMeeting.objects.create(**validated_data)


class TutorshipSerializer(serializers.Serializer):
    tutor_id = serializers.CharField(source='tutor.uuid', read_only=True)
    student_id = serializers.CharField(
        source='student.uuid', read_only=True)
    status = serializers.CharField(max_length=8)
    zoom_meeting_id = serializers.CharField(
        source='zoom_meeting.meeting_id', read_only=True)

    class Meta:
        model = models.Tutorship
        fields = ('tutor_id', 'student_id', 'status',
                  'zoom_meeting_meeting_id')

    # def create(self, validated_data):
        # return models.Tutorship.objects.create(**validated_data)


class MessageSerializer(serializers.Serializer):
    text = serializers.CharField()
    timestamp = serializers.DateTimeField(read_only=True)

    tutorship_id = serializers.CharField(max_length=32)
    sent_by_student = serializers.BooleanField()
    # sender_id = serializers.CharField(read_only=True, max_length=32, source='sender.uuid')

    # has_attachment = serializers.BooleanField(default=False)
    attachments_folder_prefix = serializers.CharField(
        max_length=1024, default=None)

    class Meta:
        model = models.Message
        fields = ('text', 'timestamp', 'sent_by_student',
                  'tutorship_id', 'sender_id', 'attachments_folder_prefix')

    def create(self, validated_data):
        return models.Message.objects.create(**validated_data)
