from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Location, School, Student

admin.site.register(User, UserAdmin)
admin.site.register([Location, School, Student])