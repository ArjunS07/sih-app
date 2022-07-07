import uuid

from django.db import models
from django.contrib.auth.models import AbstractUser
import django.contrib.postgres.fields
from django.contrib.postgres.fields import ArrayField

from multiselectfield import MultiSelectField

from .choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES

class User(AbstractUser):
    # Must have the same email as their zoom account
    pass


class PlatformUser(User):
    name_id = models.TextField(primary_key=True, editable=False)
    language_medium = MultiSelectField(choices=LANGUAGE_MEDIUM_CHOICES, null=True, blank=True)
    city = models.charfield(choices=CITY_CHOICES, null=True, blank=True)

    def save(self, *args, **kwargs):
        # Object hasn't been created in the DB yet
        if not self.pk:
            # Make a UUID from the username
            self.name_id = uuid.uuid5(uuid.NAMESPACE_DNS, self.username)
    
class School(models.Model):
    account = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.TextField(default=None, null=True)

class Student(models.Model):
    account = models.OneToOneField(PlatformUser, on_delete=models.CASCADE)
    school = models.ForeignKey(School, on_delete=models.CASCADE) 

    # Personal info
    board = models.CharField(max_length=16, choices=BOARD_CHOICES)
    grade = models.CharField(max_length=2, choices=GRADE_CHOICES)
    subjects = MultiSelectField(choices=SUBJECT_CHOICES, max_length=8)

class Tutor(models.Model):
    account = models.OneToOneField(PlatformUser, on_delete=models.CASCADE)
    
    # Personal info
    subjects = MultiSelectField(choices=SUBJECT_CHOICES, max_length=8)
    grade_range = ArrayField(models.CharField(max_length=2, choices=GRADE_CHOICES), size=2)