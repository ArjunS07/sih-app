import uuid

from django.db import models
from django.contrib.auth.models import AbstractUser
import django.contrib.postgres.fields
from multiselectfield import MultiSelectField

from api.choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES


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