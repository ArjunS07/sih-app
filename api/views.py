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

from .models import School, Student, Tutor, Tutorship, Message, ZoomMeeting
from . import serializers
from .choices import SUBJECT_CHOICES, LANGUAGE_MEDIUM_CHOICES, GRADE_CHOICES, BOARD_CHOICES, all_choices



class TutorView(APIView):
    def get(self, request, format=None):
        uuid = request.query_params.get('uuid', None)
        if uuid is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        tutor = Tutor.objects.get(uuid=uuid)
        serialized_tutor = serializers.TutorSerializer(tutor)
        res = JSONRenderer().render(serialized_tutor.data)
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)

    def post(self, request, format=None):
        data = request.POST
        json_data = json.dumps(data.dict()).encode('utf-8')
        stream = io.BytesIO(json_data)
        data = JSONParser().parse(stream)
        try:
            languages = data['languages'].split(',')
            data['languages'] = languages
            boards = data['boards'].split(',')
            data['boards'] = boards
            subjects = data['subjects'].split(',')
            data['subjects'] = subjects
            grades = data['grades'].split(',')
            data['grades'] = grades
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        serializer = serializers.TutorSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)


class StudentView(APIView):
    def get(self, request, format=None):
        uuid = request.query_params.get('uuid', None)
        if uuid is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        student = Student.objects.get(uuid=uuid)
        serialized_student = serializers.StudentSerializer(student)
        res = JSONRenderer().render(serialized_student.data)
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)

    def post(self, request, format=None):
        data = request.POST
        json_data = json.dumps(data.dict()).encode('utf-8')
        stream = io.BytesIO(json_data)
        data = JSONParser().parse(stream)
        try:
            languages = data['languages'].split(',')
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        data['languages'] = languages

        print(data)
        serializer = serializers.StudentSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


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
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)


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
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)

    def post(self, request, format=None):
        data = request.POST
        json_data = json.dumps(data.dict()).encode('utf-8')
        stream = io.BytesIO(json_data)
        data = JSONParser().parse(stream)
        serializer = serializers.TutorshipSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return HttpResponse(serializer.data, content_type='application/json', status=status.HTTP_201_CREATED)
        else:
            return HttpResponse(serializer.errors, content_type='application/json', status=status.HTTP_400_BAD_REQUEST)


class JoinSchoolView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        join_code = data.get('join_code', None)
        if not join_code:
            return HttpResponse(status=status.HTTP_400_BAD_REQUEST)
        try:
            school = School.objects.get(join_code=join_code)
            serialized_school = serializers.SchoolSerializer(school)
            res = JSONRenderer().render(serialized_school.data)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)

    def post(self, request, format=None):
        data = request.POST
        school_join_code = data['join_code']
        student_uuid = data['student_uuid']
        try:
            matching_school = School.objects.get(join_code=school_join_code)
            student = Student.objects.get(uuid=student_uuid)
            student.school = matching_school
            student.save()
            return HttpResponse('Updated student', status=status.HTTP_200_OK)
        except:
            return HttpResponse('No matching school for join code', school_join_code)


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
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
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
            return HttpResponse(serializer.data, content_type='application/json',  status=status.HTTP_201_CREATED)

        return HttpResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ZoomMeetingView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        meeting_id = data.get('meeting_id', None)
        if not meeting_id:
            return HttpResponse('Missing meeting id', status=status.HTTP_400_BAD_REQUEST)
        meeting = ZoomMeeting.objects.get(meeting_id=meeting_id)
        serialized_meeting = serializers.ZoomMeetingSerializer(meeting)
        res = JSONRenderer().render(serialized_meeting.data)
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)

    # The only thing we want to change is the  num occurrences
    def post(self, request, format=None):
        meeting_id = request.POST.get('meeting_id', None)
        new_occurrence = request.POST.get('occurence_changed', None)
        if meeting_id and new_occurrence:
            try:
                meeting = ZoomMeeting.objects.get(meeting_id=meeting_id)
            except:
                return HttpResponse('No meeting found', status=status.HTTP_404_NOT_FOUND)
            meeting.num_occurences += 1
            meeting.save()
            return HttpResponse('Updated meeting', status=status.HTTP_200_OK)
        else:
            return HttpResponse('Missing meeting id or occurrence', status=status.HTTP_400_BAD_REQUEST)


"""
    def get(self, request, format=None):
        uuid = request.query_params.get('uuid', None)
        if uuid is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        tutor = Tutor.objects.get(uuid=uuid)
        serialized_tutor = serializers.TutorSerializer(tutor)
        res = JSONRenderer().render(serialized_tutor.data)
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)

    def post(self, request, format=None):
        data = request.POST
        json_data = json.dumps(data.dict()).encode('utf-8')
        stream = io.BytesIO(json_data)
        data = JSONParser().parse(stream)
        serializer = serializers.TutorSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
"""
