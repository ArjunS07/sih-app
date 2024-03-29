from django.contrib.auth import login, authenticate
from django.conf import settings
from django.contrib.auth.forms import UserCreationForm

from django import forms
from api.models import School
from api.choices import CITY_CHOICES
from accounts.models import User


class SchoolCreationForm(forms.ModelForm):
    school_name = forms.CharField(max_length=128, required=True, widget=forms.TextInput(
        attrs={'placeholder': 'School name', 'class': 'input'}))
    school_city = forms.ChoiceField(choices=CITY_CHOICES, required=True, widget=forms.Select(
        attrs={'class': 'input'}))
    account__email = forms.EmailField(required=True, widget = forms.EmailInput(
        attrs={'placeholder': 'Email', 'class': 'input'}))
    
    account__password1 = forms.CharField(
        widget=forms.PasswordInput(attrs = {'placeholder': 'Password', 'class': 'input'}), required=True)
    account__password2 = forms.CharField(
        widget=forms.PasswordInput(attrs = {'placeholder': 'Confirm password', 'class': 'input'}), required=True)

    class Meta:
        fields = 'account__email', 'account__password1', 'account__password2', 'school_name', 'school_city'
        model = School
    
    def clean_account__email(self):
        email = self.cleaned_data['account__email']
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError('Email already exists')
        return email

class SchoolLoginForm(forms.ModelForm):
    account__email = forms.EmailField(required=True, widget = forms.EmailInput(
        attrs={'placeholder': 'Email', 'class': 'input'}))
    account__password = forms.CharField(
        widget=forms.PasswordInput(attrs = {'placeholder': 'Password', 'class': 'input'}), required=True)

    class Meta:
        fields = 'account__email', 'account__password'
        model = User
    
    def clean(self):
        email = self.cleaned_data['account__email']
        password = self.cleaned_data['account__password']
        if not authenticate(email=email, password=password):
            raise forms.ValidationError('Invalid email or password')
        return self.cleaned_data
