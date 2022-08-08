from pipes import Template
from django.urls import path, include

from . import views

urlpatterns = [
    path('signup', views.SchoolSignUp.as_view(), name='school_signup'),
    path('login', views.LoginView.as_view(), name='school_login'),
    path('dashboard', views.SchoolDashboard.as_view(), name='school_dashboard'),
    path('logout', views.logout_view, name='logout'),
]