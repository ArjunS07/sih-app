from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator

from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.views.generic import View
from django.urls import reverse

from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import user_passes_test

from accounts.models import User
from api.models import School
from api.choices import CITY_CHOICES

from .forms import SchoolCreationForm, SchoolLoginForm

def unauthenticated_required(view_func=None):
    actual_decorator = user_passes_test(
        lambda u: not u.is_active and not u.is_authenticated,
    )
    if view_func:
        return actual_decorator(view_func)
    return actual_decorator

class SchoolSignUp(View):
    def post(self, request):

        if request.user.is_authenticated:
            return HttpResponseRedirect(reverse('school_dashboard'))
        form = SchoolCreationForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            email = data['account__email']

            user = User.objects.create_user(
                email=email,
                password=data['account__password1'],
            )

            user.save()
            if user is not None:
                login(request, user)
            school = School.objects.create(
                account=user,
                name=data['school_name'],
                city=data['school_city']
            )
            school.save()
            return HttpResponseRedirect(reverse('dashboard'))
        else:
            return render(request, 'core/school_signup.html', context={'form': form}) 

    def get(self, request):
        if request.user.is_authenticated:
            return HttpResponseRedirect(reverse('school_dashboard'))
        form = SchoolCreationForm()
        context = {
            # 'city_options': CITY_CHOICES,
            'form': form
        }
        return render(request, 'core/school_signup.html', context=context)      

from django.contrib.auth import logout

class LoginView(View):
    def get(self, request):
        if request.user.is_authenticated:
            return HttpResponseRedirect(reverse('school_dashboard'))
        form = SchoolLoginForm()
        context = {'form': form}
        return render(request, 'core/school_login.html', context=context)
    
    def post(self, request):
        if request.user.is_authenticated:
            return HttpResponseRedirect(reverse('school_dashboard'))
        form = SchoolLoginForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            email = data['account__email']
            user = authenticate(email=email, password=data['account__password'])
            if user is not None:
                login(request, user)
                return HttpResponseRedirect(reverse('school_dashboard'))
        return render(request, 'core/school_login.html', context={'form': form})

def logout_view(request):
    logout(request)
    return HttpResponseRedirect(reverse('school_login'))

class SchoolDashboard(View):
    @method_decorator(login_required())
    def get(self, request):
        return HttpResponse('Hello')
