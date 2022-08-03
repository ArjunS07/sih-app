from pipes import Template
from django.urls import path, include

from . import views

urlpatterns = [
    path('test', views.test, name='test')
]