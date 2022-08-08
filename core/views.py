from django.conf import settings

from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.views.generic import View
from django.urls import reverse


from accounts.models import User
from api.models import School
from api.choices import CITY_CHOICES

from .forms import SchoolCreationForm
# Create your views here.


def index(request):
    return HttpResponse('Hello')


class SchoolSignUp(View):

    def post(self, request):
        form = SchoolCreationForm(request.POST)

        if form.is_valid():
            data = form.cleaned_data
            email = data['account__email']

            user = User.objects.create_user(
                email=email,
                password=data['account__password1'],
            )

            user.save()
            school = School.objects.create(
                account=user,
                name=data['school_name'],
                city=data['school_city']
            )
            school.save()
            return HttpResponse('Success')
        else:
            return render(request, 'core/school_signup.html', context={'form': form}) 

    def get(self, request):
        form = SchoolCreationForm()
        context = {
            # 'city_options': CITY_CHOICES,
            'form': form
        }
        return render(request, 'core/school_signup.html', context=context)      

        


class SchoolDashboard(View):
    pass
