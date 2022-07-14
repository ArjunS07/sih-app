from functools import reduce
import operator
import io
import json

from django.http import HttpResponse
from django.shortcuts import render
from django.db.models import Q
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import JSONParser

from .models import School, Student, Tutor, Tutorship, Message
from . import serializers
from .choices import SUBJECT_CHOICES, LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, BOARD_CHOICES, all_choices


class TutorListView(APIView):
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

        serialized_tutors = serializers.TutorSerializer(
            matching_tutors, many=True)
        res = JSONRenderer().render(serialized_tutors.data)
        return HttpResponse(res, status=status.HTTP_200_OK)


class TutorshipView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        print(request)
        tutorship_id = data['id']
        try:
            tutorship = Tutorship.objects.get(id=tutorship_id)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)

        serialized_tutorship = serializers.TutorshipSerializer(tutorship)
        res = JSONRenderer().render(serialized_tutorship.data)
        return HttpResponse(res, status=status.HTTP_200_OK)


class JoinSchoolView(APIView):
    def post(self, request, format=None):
        data = request.POST
        school_join_code = data['join_code']
        student_name_id = data['student_name_id']
        matching_school = School.objects.get(join_code=school_join_code)
        if not matching_school:
            return HttpResponse('No matching school for join code', school_join_code)

        student = Student.objects.get(name_id=student_name_id)
        student.school = matching_school
        student.save()
        return Response('Updated student', status=status.HTTP_200_OK)


class MessageView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        print(request)
        try:
            id = data['id']
        except:
            return HttpResponse('Missing message id', status=status.HTTP_400_BAD_REQUEST)
        try:
            message = Message.objects.get(id=id)
            print('Got message', message)
            serialized_message = serializers.MessageSerializer(message)
            print('serialized message to', serialized_message)
            res = JSONRenderer().render(serialized_message.data)
            print('rendered', res)
            return HttpResponse(res, status=status.HTTP_200_OK)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)

    def post(self, request, format=None):
        data = request.POST
        json_data = json.dumps(data.dict()).encode('utf-8')
        stream = io.BytesIO(json_data)
        data = JSONParser().parse(stream)
        print(data)
        serializer = serializers.MessageSerializer(data=data)
        print(serializer)
        if serializer.is_valid():
            print(serializer.validated_data)
            message = serializer.save()
            print(message)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)