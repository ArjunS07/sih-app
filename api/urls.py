from django.urls import path, include
from . import views

urlpatterns = [
    path('tutors', views.TutorListView.as_view(), name='tutors'),
    path('tutorship', views.TutorshipView.as_view(), name='tutorship'),
    path('joinschool', views.JoinSchoolView.as_view(), name='joinschool'),
    path('messages', views.MessageView.as_view(), name='messages'),
]