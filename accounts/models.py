import uuid

from django.db import models
from django.contrib.auth.models import AbstractUser
import django.contrib.postgres.fields

from multiselectfield import MultiSelectField

from api.models import Tutorship
from ..api.choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES

class User(AbstractUser):
    # Must have the same email as their zoom account
    pass


class PlatformUser(User):
    name_id = models.CharField(primary_key=True, editable=False, max_length=128)
    language_medium = MultiSelectField(choices=LANGUAGE_MEDIUM_CHOICES, null=True, blank=True)
    city = models.CharField(choices=CITY_CHOICES, null=True, blank=True, max_length=32)

    def __init__(self, name_id, language_medium, city):
        self.name_id = uuid.uuid5(uuid.NAMESPACE_DNS, self.username)
        self.language_medium = language_medium
        self.city = city    
class School(models.Model):
    account = models.OneToOneField(User, on_delete=models.CASCADE)
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