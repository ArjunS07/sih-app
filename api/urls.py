from django.urls import path, include
from . import views

urlpatterns = [
    path('tutor', views.TutorView.as_view(), name='tutor'),
    path('student', views.StudentView.as_view(), name='student'),
    path('tutors', views.TutorListView.as_view(), name='tutors'),
    path('joinschool', views.JoinSchoolView.as_view(), name='joinschool'),

    path('tutorship', views.TutorshipView.as_view(), name='tutorship'),
    path('messages', views.MessageView.as_view(), name='messages'),
    path('zoommeeting', views.ZoomMeetingView.as_view(), name='zoommeeting'),

]