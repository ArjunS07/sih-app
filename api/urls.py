from django.urls import path, include
from . import views

urlpatterns = [
    path('tutors', views.TutorList.as_view(), name='tutors'),
]