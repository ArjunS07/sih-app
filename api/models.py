from contextlib import nullcontext
from email.policy import default
import uuid

from django.db import models
from django.utils.translation import gettext_lazy as _
from multiselectfield import MultiSelectField

from accounts.models import User, PlatformUser
from .choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES

from .utils.zoom_utils import generate_zoom_meeting

class School(models.Model):
    account = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(default=None, null=True, max_length=128)
    city = models.CharField(default=None, null=True, max_length=16, choices=CITY_CHOICES)
    join_code = models.CharField(default=None, null=True, max_length=6, editable=False)

    def __str__(self) -> str:
        return self.name
    
    def save(self, *args, **kwargs):
        if not self.join_code:
            code = uuid.uuid4().hex.upper()[0:6]
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
    def active_tutorships(self):
        return Tutorship.objects.filter(tutor=self)

    @property
    def num_active_tutorships(self) -> int:
        return len(self.active_tutorships)
    
    @property
    def active_tutorship_students(self):
        students = []
        for tutorship in self.active_tutorships:
            students.append(tutorship.student)
        return students

class ZoomMeeting(models.Model):
    # start url for tutors, join_url for students. tutors always start the meeting
    start_url = models.CharField(max_length=1024, default=None, null=True)
    join_url = models.CharField(max_length=1024, default=None, null=True)

    meeting_id = models.CharField(primary_key=True, max_length=32)
    meeting_password = models.CharField(max_length=1024, default=None, null=True)
    meeting_encrypted_password = models.CharField(max_length=1024, default=None, null=True)

    def __str__(self) -> str:
        return self.join_url


class Tutorship(models.Model):
    tutor = models.ForeignKey(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.ForeignKey(Student, null=True, on_delete=models.SET_NULL)
    zoom_meeting = models.ForeignKey(ZoomMeeting, editable=False, null=True, default = None, on_delete=models.SET_NULL)
    tutorship_subjects = MultiSelectField(
        choices=SUBJECT_CHOICES, max_length=1024, default=None, null=True)

    created = models.DateTimeField(auto_now_add=True, null=True, editable=False)
    class TutorshipStatus(models.TextChoices):
        PENDING = 'PNDG', _('Pending')
        ACCEPTED = 'ACPT', _('Accepted')
        REJECTED = 'RJCT', _('Rejected')
        SUSPENDED = 'SUSPND', _('Suspended')

    status = models.CharField(choices=TutorshipStatus.choices, default=TutorshipStatus.PENDING, max_length=8)
   
    @property
    def tutorship_firebase_folder_path(self):
        return f'tutorships/{self.id}/'

    def __str__(self) -> str:
        return f'Room with {self.tutor} and {self.student}'
    
    def save(self, *args, **kwargs):
        if self.status == 'ACPT' and self.zoom_meeting is None:
            generated_zoom_details = generate_zoom_meeting(tutor_name=self.tutor.name, student_name=self.student.name)
            zoom_meeting = ZoomMeeting(
                meeting_id=generated_zoom_details['meeting_id'],
                meeting_password=generated_zoom_details['meeting_password'],
                meeting_encrypted_password=generated_zoom_details['meeting_encrypted_password'],
                start_url=generated_zoom_details['start_url'],
                join_url=generated_zoom_details['join_url'],
            )
            zoom_meeting.save()
            self.zoom_meeting = zoom_meeting
        super(Tutorship, self).save(*args, **kwargs)

class TutorshipReport(models.Model):
    tutorship = models.ForeignKey(Tutorship, on_delete=models.CASCADE)
    sender_uuid = models.CharField(max_length=36, default=None, null=True)
    description = models.TextField(default=None, null=True)
    created = models.DateTimeField(auto_now_add=True, null=True, editable=False)

    def __str__(self):
        return f'{self.description} by {self.sender_uuid}'
    
    def save(self, *args, **kwargs):
        if not self.pk:
            # send an email to the student's school
            student_school = self.tutorship.student.school
            student_school_email = student_school.account.email
            pass

            # suspend the tutorship
            self.tutorship.status = 'SUSPND'
            self.tutorship.save()
            print('updated tutorship status')
        super(TutorshipReport, self).save(*args, **kwargs)