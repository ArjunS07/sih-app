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
    join_code = models.CharField(default=None, null=True, max_length=10)

    def __str__(self) -> str:
        return self.name

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
    school = models.ForeignKey(School, on_delete=models.CASCADE)
    board = models.CharField(choices=BOARD_CHOICES,
                             max_length=8, default=None, null=True, blank=True)
    grade = models.CharField(choices=GRADE_CHOICES,
                             max_length=8, default=None, null=True)

    def __str__(self) -> str:
        return self.name_id


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


class Tutorship(models.Model):
    tutor = models.ForeignKey(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.ForeignKey(Student, null=True, on_delete=models.SET_NULL)

    class TutorshipStatus(models.TextChoices):
        PENDING = 'PNDG', _('Pending')
        ACCEPTED = 'ACPT', _('Accepted')
        REJECTED = 'RJCT', _('Rejected')

    status = models.CharField(choices=TutorshipStatus.choices, default=TutorshipStatus.PENDING, max_length=8)

    # Zoom stuff
    # TODO: @ayati add whatever fields you want here

    # Need something that automatically generates these when the model is initialised. add code that directly interacts with zoom in utils/zoom_utils and
    meeting_link = models.TextField(default=None, null=True)
    invite = models.TextField(default=None, null=True)

    @property
    def tutorship_zoom_link(self):
        # You can turn functions into variables like this. we need them to be variables so that we can directly show them in the frontend HTML as tutorship.zoom_link, even if zoom_link() is a function
        return self.meeting_link  # TODO: CHANGE

    # TODO: Add S3 stuff here
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

    @ property
    def has_attachment(self) -> bool:
        return self.attachments_key_prefix != None
