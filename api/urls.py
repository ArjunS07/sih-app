from django.urls import path, include
from . import views

urlpatterns = [
    path('userfromaccount', views.UserFromAccount.as_view(), name='userfromaccount'),   
    path('tutors', views.TutorView.as_view(), name='tutor'),
    path('students', views.StudentView.as_view(), name='student'),
    path('tutorslist', views.TutorListView.as_view(), name='tutors'),
    path('joinschool', views.JoinSchoolView.as_view(), name='joinschool'),
    path('tutorships', views.TutorshipView.as_view(), name='tutorships'),
    path('mytutorshipslist', views.MyTutorshipsView.as_view(), name='mytutorshipslist'),
    path('meetings', views.ZoomMeetingView.as_view(), name='zoommeeting'),
    path('messages', views.MessageView.as_view(), name='messages'),

]