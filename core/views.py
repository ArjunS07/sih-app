from django.http import HttpResponse
from django.shortcuts import render
from django.views.generic import View

from django.conf import settings


from accounts.models import User
from api.models import School
from api.choices import CITY_CHOICES

from .forms import SchoolCreationForm
# Create your views here.


def index(request):
    return HttpResponse('Hello')


class SchoolSignUp(View):
    def get(self, request):
        form = SchoolCreationForm()
        context = {
            # 'city_options': CITY_CHOICES,
            'form': form
        }
        return render(request, 'core/school_signup.html', context=context)

    def post(self, request):
        data = request.POST
        print(data)

        form = SchoolCreationForm(data)
        if form.is_valid():
            user = User.objects.create_user(
                email=data['account__email'],
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
            print(form.errors)


        # schoolUserAccount = User.objects.create_user(
        #     email=data['school_email'], password=data['password1'])

        # school = School.objects.create(
        #     name=data['school_name'],
        #     city=data['school_city'],
        #     user=schoolUserAccount
        # )

        # return HttpResponse(school)


class SchoolDashboard(View):
    pass
