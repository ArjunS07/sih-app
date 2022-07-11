import uuid

from django.db import models

from multiselectfield import MultiSelectField

from accounts.models import PlatformUser
from .choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES

class School(models.Model):
    account = models.OneToOneField(PlatformUser, on_delete=models.CASCADE)
    name = models.TextField(default=None, null=True)

    @property
    def school_students(self) -> int:
        return (Student.objects.filter(school=self, is_active=True))
    
    @property
    def name_id(self) -> str:
        return self.account.name_id
    
    @property
    def email(self) -> str:
        return self.account.email
    
    

class Student(models.Model):
    account = models.OneToOneField(PlatformUser, on_delete=models.CASCADE)
    school = models.ForeignKey(School, on_delete=models.CASCADE) 

    # Personal info
    board = models.CharField(max_length=16, choices=BOARD_CHOICES, null=True, blank=True)
    grade = models.CharField(max_length=2, choices=GRADE_CHOICES)
    subjects = MultiSelectField(choices=SUBJECT_CHOICES, max_length=8)

    @property
    def is_active(self) -> bool:
        return self.account.is_active

class Tutor(models.Model):
    account = models.OneToOneField(PlatformUser, on_delete=models.CASCADE)
    
    # Personal info
    subjects = MultiSelectField(choices=SUBJECT_CHOICES, max_length=8)
    grade_range = MultiSelectField(choices=GRADE_CHOICES, max_length=12)

    @property
    def get_tutor_active_mentorships(self) -> int:
        return Tutorship.objects.get(tutor=self)

class Tutorship(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tutor = models.ForeignKey(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.ForeignKey(Student, null=True, on_delete=models.SET_NULL)

    # Zoom stuff
    # TODO: @ayati add whatever fields you want here

    # Need something that automatically generates these when the model is initialised. add code that directly interacts with zoom in utils/zoom_utils and 
    meeting_link = models.TextField(default=None, null=True)
    invite = models.TextField(default=None, null=True)

    @property
    def tutorship_zoom_link(self):
        # You can turn functions into variables like this. we need them to be variables so that we can directly show them in the frontend HTML as tutorship.zoom_link, even if zoom_link() is a function
        return self.meeting_link # TODO: CHANGE
    
    #TODO: Add S3 stuff here
    # We need to make a folder on S3 for this tutorship with subfolders, be able to save / get the folder link (we can manually assemble it with this function each time)
    @property
    def tutorship_s3_folder_path(self):
        pass

class Message(models.Model):
    room = models.ForeignKey(Tutorship, on_delete=models.CASCADE)
    time_sent = models.DateTimeField(auto_now=True)
    text = models.CharField(max_length=2048)

    # Link to prefix on S3 for attachments. This will allow us to store the folder URL directly and download all keys from that folder
    attachments_key_prefix = models.CharField(max_length=256)

    @property
    def has_attachment(self) -> bool:
        return self.attachments_key_prefix != None