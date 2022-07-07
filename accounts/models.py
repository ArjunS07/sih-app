import uuid

from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    # Must have the same email as their zoom account
    pass

class Location(models.Model):
    latitude = models.FloatField()
    longitude = models.FloatField()
    
class Platformuser(User):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    location = models.ForeignKey(Location)
    
class School(User):
    pass
class Student(User):
    pass
    
class Tutor(User):
    pass