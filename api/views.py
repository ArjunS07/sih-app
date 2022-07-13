from functools import reduce
import operator

from django.http import HttpResponse
from django.shortcuts import render
from django.db.models import Q
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework import status

from .models import School, Tutor
from . import serializers
from .choices import SUBJECT_CHOICES, LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, BOARD_CHOICES, all_choices

class TutorList(APIView):
    def get(self, request, format=None):
        data = request.query_params
        print(request)
        q = []
        if 'languages' in data:
            languages = data['languages'].split(',')
            for language in languages:
                q.append(Q(languages__contains=language))
        if 'boards' in data:
            boards = data['boards'].split(',')
            for board in boards:
                q.append(Q(boards__contains=board))
        if 'subjects' in data: 
            subjects = data['subjects'].split(',')
            for subject in subjects:
                print(subject)
                q.append(Q(subjects__contains=subject))
        if 'grades' in data: 
            grades = data['grades'].split(',')
            for grade in grades:
                q.append(Q(grades__contains=grade))

        if len(q) > 0:
            matching_tutors = Tutor.objects.filter(
                reduce(operator.and_, q)
            )
        else:
            matching_tutors = Tutor.objects.all()

        print(matching_tutors)

        serialized_tutors = serializers.TutorSerializer(matching_tutors, many=True)
        res = JSONRenderer().render(serialized_tutors.data)
        return HttpResponse(res, status=status.HTTP_200_OK)

class Tutorship(APIView):
    def get(self, request, format=None):
        data = request.query_


def JoinSchool(APIView):
    def post(self, request, format=None):
        data = request.POST
        school_join_code = data['join_code']
        student_name_id = data['student_name_id']
        matching_school = School.objects.get(join_code=school_join_code)
        if not matching_school:
            return HttpResponse('No matching school for join code', school_join_code)

        student = student.objects.get(name_id=student_name_id)
        student.school = matching_school
        student.save()
        return Response('Created student', status=status.HTTP_201_CREATED)