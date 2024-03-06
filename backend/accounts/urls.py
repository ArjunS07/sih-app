from django.urls import path, re_path
from dj_rest_auth.registration.views import RegisterView, VerifyEmailView
from dj_rest_auth.views import LoginView, LogoutView
from dj_rest_auth.views import PasswordResetView, PasswordResetConfirmView

from . import views

urlpatterns = [
    path('register/', RegisterView.as_view()),
    path('login/', LoginView.as_view()),
    path('logout/', LogoutView.as_view()),
    path('password-reset/', PasswordResetView.as_view()),
    path('password-reset-confirm/<uidb64>/<token>/',
        PasswordResetConfirmView.as_view(), name='password_reset_confirm'),  
    path('api-token-auth/', views.CustomAuthToken.as_view()),
    path('users', views.UserView.as_view(), name='users'),
]