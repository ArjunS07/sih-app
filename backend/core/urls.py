from pipes import Template
from django.urls import path, include

from . import views

urlpatterns = [
    path('signup', views.SchoolSignUp.as_view(), name='school_signup'),
    path('login', views.LoginView.as_view(), name='school_login'),
    path('dashboard', views.SchoolDashboard.as_view(), name='school_dashboard'),
    path('dashboard/student/<student_uuid>', views.StudentDetailView.as_view(), name='student_detail'),
    path('logout', views.logout_view, name='logout'),
    path('messageslog/<tutorship_id>', views.MessageLogView.as_view(), name='messageslog')
]