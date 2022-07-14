import uuid
import re

from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
import django.contrib.postgres.fields
from django.utils.translation import gettext_lazy as _
from multiselectfield import MultiSelectField

from api.choices import LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, CITY_CHOICES, BOARD_CHOICES, SUBJECT_CHOICES


class UserManager(BaseUserManager):
    """Define a model manager for User model with no username field."""

    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        """Create and save a User with the given email and password."""
        if not email:
            raise ValueError('The given email must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        """Create and save a regular User with the given email and password."""
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password, **extra_fields):
        """Create and save a SuperUser with the given email and password."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    """User model."""

    username = None
    email = models.EmailField(_('email address'), unique=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = UserManager()


class PlatformUser(models.Model):
    account = models.OneToOneField(
        User, on_delete=models.CASCADE, default=None, null=True)
    name_id = models.CharField(primary_key=True, editable=False, max_length=128, default="")

    city = models.CharField(choices=CITY_CHOICES,
                            max_length=8, default=None, null=True, blank=True)
    languages = MultiSelectField(
        choices=LANGUAGE_MEDIUM_CHOICES, max_length=1024, default=None, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.name_id:
            name = self.account.email.split('@')[0]
            name = re.sub("[!@#$%^&*()[]{};:,./<>?\|`~-=_+]", " ", name)
            self.name_id = name + str(uuid.uuid4())[:16].replace('-', '')
        super(PlatformUser, self).save(*args, **kwargs)

    # Personal info
    @property
    def profile_image_s3_path(self):
        # TODO: Do whatever here
        return f"s3_url/profile_images/{self.name_id}.jpg"

    def __str__(self) -> str:
        return self.name_id

    class Meta:
        abstract = True
