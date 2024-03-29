from contextlib import nullcontext
from email.policy import default
import uuid

from django.db import models
from django.urls import reverse

from django.utils.translation import gettext_lazy as _
from django.core.validators import MaxValueValidator, MinValueValidator

from multiselectfield import MultiSelectField

from accounts.models import User, PlatformUser
from .choices import GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES, EDUCATIONAL_LEVEL_CHOICES, decode_choice

from .utils.zoom_utils import generate_zoom_meeting


class School(models.Model):
    account = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(default=None, null=True, max_length=128)
    city = models.CharField(default=None, null=True,
                            max_length=16, choices=CITY_CHOICES)
    join_code = models.CharField(
        default=None, null=True, max_length=6, editable=False)

    def __str__(self) -> str:
        return self.name

    def save(self, *args, **kwargs):
        if not self.join_code:
            code = uuid.uuid4().hex.upper()[0:6]
            self.join_code = code
        super(School, self).save(*args, **kwargs)

    @property
    def num__students(self) -> int:
        return (Student.objects.filter(school=self, is_active=True).count())

    @property
    def students(self) -> int:
        return (Student.objects.filter(school=self))

    @property
    def email(self) -> str:
        return self.account.email


class Student(PlatformUser):
    school = models.ForeignKey(
        School, on_delete=models.CASCADE, null=True, default=None, blank=True)
    board = models.CharField(choices=BOARD_CHOICES,
                             max_length=8, default=None, null=True, blank=True)
    grade = models.CharField(choices=GRADE_CHOICES,
                             max_length=8, default=None, null=True)

    @property
    def decoded_grade(self):
        return decode_choice(GRADE_CHOICES, self.grade)

    @property
    def tutorships(self):
        return Tutorship.objects.filter(student=self)

    @property
    def num_tutorships(self) -> int:
        return len(self.tutorships)
    
    @property
    def detail_url(self) -> str:
        return reverse('student_detail', kwargs={'student_uuid': self.uuid})


class Tutor(PlatformUser):
    grades = MultiSelectField(choices=GRADE_CHOICES,
                              max_length=128, default=None, null=True)
    boards = MultiSelectField(
        choices=BOARD_CHOICES, max_length=128, default=None, null=True, blank=True)
    subjects = MultiSelectField(
        choices=SUBJECT_CHOICES, max_length=1024, default=None, null=True)
    age = models.PositiveIntegerField(default=None, null=True, validators=[MinValueValidator(15), MaxValueValidator(100)])
    highest_educational_level = models.CharField(choices=EDUCATIONAL_LEVEL_CHOICES,max_length=12, default=None, null=True)


    @property
    def active_tutorships(self):
        return Tutorship.objects.filter(tutor=self).exclude(status='RJCT')

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
    meeting_password = models.CharField(
        max_length=1024, default=None, null=True)
    meeting_encrypted_password = models.CharField(
        max_length=1024, default=None, null=True)
    
    @property
    def meeting_id_display(self):
        return f'{self.meeting_id[:3]} {self.meeting_id[3:7]} {self.meeting_id[7:]}'

    def __str__(self) -> str:
        return self.join_url


class Tutorship(models.Model):
    tutor = models.ForeignKey(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.ForeignKey(Student, null=True, on_delete=models.SET_NULL)
    zoom_meeting = models.OneToOneField(
        ZoomMeeting, editable=False, null=True, default=None, on_delete=models.SET_NULL)
    tutorship_subjects = MultiSelectField(
        choices=SUBJECT_CHOICES, max_length=1024, default=None, null=True)

    created = models.DateTimeField(
        auto_now_add=True, null=True, editable=False)

    class TutorshipStatus(models.TextChoices):
        PENDING = 'PNDG', _('Pending')
        ACCEPTED = 'ACPT', _('Active')
        REJECTED = 'RJCT', _('Rejected')
        SUSPENDED = 'SUSPND', _('Suspended')

    status = models.CharField(
        choices=TutorshipStatus.choices, default=TutorshipStatus.PENDING, max_length=8)

    @property
    def tutorship_firebase_folder_path(self):
        return f'tutorships/{self.id}/'

    @property
    def messages_log(self):
        return reverse('messageslog', kwargs={'tutorship_id': self.id})

    def __str__(self) -> str:
        return f'Room with {self.tutor} and {self.student} and subjects {self.tutorship_subjects}'

    def save(self, *args, **kwargs):
        if self.status == 'ACPT' and self.zoom_meeting is None:
            generated_zoom_details = generate_zoom_meeting(
                tutor_name=self.tutor.name, student_name=self.student.name)
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
    tutorship = models.OneToOneField(Tutorship, on_delete=models.CASCADE)
    sender_uuid = models.CharField(max_length=36, default=None, null=True)
    description = models.TextField(default=None, null=True)
    created = models.DateTimeField(
        auto_now_add=True, null=True, editable=False)

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
