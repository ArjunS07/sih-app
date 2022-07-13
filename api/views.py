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
        if request.method == 'GET':
            data = request.query_params
            print(request)
            q = []
            if 'languages' in data:
                languages = data['languages'].split(',')
                print(languages)
                q.append(Q(languages=languages))
            if 'boards' in data:
                boards = data['boards'].split(',')
                print(boards)
                q.append(Q(boards=boards))
            if 'subjects' in data: 
                subjects = data['subjects'].split(',')
                print(subjects)
                query = Q(subjects=subjects)
                q.append(query)
                print(query)
            if 'grades' in data: 
                grades = data['grades'].split(',')
                print(grades)
                query = Q(grades=grades)
                print(query)
                q.append(Q(grades=grades))

            matching_tutors = Tutor.objects.filter(
                reduce(operator.and_, q)
            )

            serialized_tutors = serializers.TutorSerializer(matching_tutors, many=True)
            res = JSONRenderer().render(serialized_tutors.data)
            return HttpResponse(res, status=status.HTTP_200_OK)

"""
try:
    languages = data['languages'].split(',')
    boards = data['boards'].split(',')
    subjects = data['subjects']

    grade_ints = data['grade_int']
except Exception as e:
    print(e)
    return HttpResponse('Missing parameters', status=status.HTTP_400_BAD_REQUEST)

grade_codes = [map_int_to_grade(grade) for grade in grade_ints]

matching_tutors = Tutor.objects.filter(
    languages=languages,
    boards=boards,
    subjects=subjects,
    grades=grade_codes,
)

return HttpResponse(matching_tutors, status=status.HTTP_200_OK)

"""
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