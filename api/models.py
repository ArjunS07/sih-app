from contextlib import nullcontext
from email.policy import default
import uuid

from django.db import models
from django.utils.translation import gettext_lazy as _
from multiselectfield import MultiSelectField

from accounts.models import User, PlatformUser
from .choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES


class School(models.Model):
    account = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(default=None, null=True, max_length=128)
    city = models.CharField(default=None, null=True, max_length=16, choices=CITY_CHOICES)
    join_code = models.CharField(default=None, null=True, max_length=10, editable=False)

    def __str__(self) -> str:
        return self.name
    
    def save(self, *args, **kwargs):
        if not self.join_code:
            code = uuid.uuid4().hex.upper()[0:8]
            self.join_code = code
        super(School, self).save(*args, **kwargs)

    @property
    def num_school_students(self) -> int:
        return (Student.objects.filter(school=self, is_active=True).count())

    @property
    def school_students(self) -> int:
        return (Student.objects.filter(school=self, is_active=True))

    @property
    def email(self) -> str:
        return self.account.email


class Student(PlatformUser):
    school = models.ForeignKey(School, on_delete=models.CASCADE, null=True, default=None, blank=True)
    board = models.CharField(choices=BOARD_CHOICES,
                             max_length=8, default=None, null=True, blank=True)
    grade = models.CharField(choices=GRADE_CHOICES,
                             max_length=8, default=None, null=True)

class Tutor(PlatformUser):
    grades = MultiSelectField(choices=GRADE_CHOICES,
                              max_length=128, default=None, null=True)
    boards = MultiSelectField(
        choices=BOARD_CHOICES, max_length=128, default=None, null=True, blank=True)
    subjects = MultiSelectField(
        choices=SUBJECT_CHOICES, max_length=1024, default=None, null=True)

    @property
    def get_tutor_active_mentorships(self) -> int:
        return Tutorship.objects.filter(tutor=self)

class ZoomMeeting(models.Model):
    link = models.CharField(max_length=1024, default=None, null=True)
    meeting_id = models.CharField(primary_key=True, max_length=32)
    meeting_password = models.CharField(max_length=1024, default=None, null=True)
    num_occurences = models.PositiveSmallIntegerField(default=1)

    def __str__(self) -> str:
        return self.link


class Tutorship(models.Model):
    tutor = models.ForeignKey(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.ForeignKey(Student, null=True, on_delete=models.SET_NULL)
    zoom_meeting = models.ForeignKey(ZoomMeeting, null=True, on_delete=models.SET_NULL)

    class TutorshipStatus(models.TextChoices):
        PENDING = 'PNDG', _('Pending')
        ACCEPTED = 'ACPT', _('Accepted')
        REJECTED = 'RJCT', _('Rejected')

    status = models.CharField(choices=TutorshipStatus.choices, default=TutorshipStatus.PENDING, max_length=8)
   
    @property
    def tutorship_s3_folder_path(self):
        pass

    def __str__(self) -> str:
        return f'Room with {self.tutor} and {self.student}'

class Message(models.Model):
    text = models.CharField(max_length=2048, default=None, null=True)
    time_sent = models.DateTimeField(auto_now=True)

    tutorship_id = models.IntegerField(default=None, null=True)
    sent_by_student = models.BooleanField(default=False)

    @property
    def tutorship(self):
        return Tutorship.objects.get(id=self.tutorship_id)
    
    @property
    def sender(self):
        if self.sent_by_student:
            return self.tutorship.student
        else:
            return self.tutorship.tutor
        
    # Link to prefix on S3 for attachments. This will allow us to store the folder URL directly and download all keys from that folder
    attachments_folder_prefix = models.CharField(max_length=1024, null=True, default=None, blank=True)

    @property
    def has_attachment(self) -> bool:
        return self.attachments_key_prefix != None

    def __str__(self) -> str:
        return f'{self.text}'