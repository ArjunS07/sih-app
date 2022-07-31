from functools import reduce
from nis import match
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


class UserFromAccount(APIView):
    def get(self, request):
        account_id = request.query_params.get('account_id')
        if not account_id:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        try:
            student = Student.objects.get(account__id=account_id)
            serialized = serializers.StudentSerializer(student)
            res = {'type': 'student', 'user': serialized.data}
            res = JSONRenderer().render(res)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
        except Student.DoesNotExist:
            try:
                tutor = Tutor.objects.get(account__id=account_id)
                serialized = serializers.TutorSerializer(tutor)
                res = {'type': 'tutor', 'user': serialized.data}
                res = JSONRenderer().render(res)
                return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
            except Tutor.DoesNotExist:
                return HttpResponse(status=status.HTTP_404_NOT_FOUND)


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
        print(f"Recieved {data} for a post request to tutors ")
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
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


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
        print(f'Got request to tutor list {request}')

        student_uuid = data.get('student_uuid', None)
        if not student_uuid:
            return HttpResponse(status=status.HTTP_400_BAD_REQUEST)

        try:
            matching_student = Student.objects.get(uuid=student_uuid)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)

        q = []
        # Within a category = or.
        if 'languages' in data:
            # A student may speak 5 languages and upload all 5. We need to find tutors who just speak any 1 of those 5, so we use the or operator
            languages = data['languages'].split(',')
            q_objects = []
            for language in languages:
                q_objects.append(Q(languages__contains=language))
            combined = reduce(operator.or_, q_objects)
            q.append(combined)
        if 'boards' in data:
            boards = data['boards'].split(',')
            q_objects = []
            for board in boards:
                q_objects.append(Q(boards__contains=board))
            combined = reduce(operator.or_, q_objects)
            print(combined)
            q.append(combined)
        if 'subjects' in data:
            subjects = data['subjects'].split(',')
            print('Split subjects into', subjects)
            q_objects = []
            for subject in subjects:
                q_objects.append(Q(subjects__contains=subject))
            combined = reduce(operator.or_, q_objects)
            print(combined)
            q.append(combined)
        if 'grades' in data:
            grades = data['grades'].split(',')
            q_objects = []
            for grade in grades:
                q_objects.append(Q(grades__contains=grade))
            combined = reduce(operator.or_, q_objects)
            print(combined)
            q.append(combined)
        print(q)

        if len(q) > 0:
            matching_tutors = Tutor.objects.filter(
                reduce(operator.and_, q)
            )
        else:
            matching_tutors = Tutor.objects.all()

        matching_tutors = [tutor for tutor in matching_tutors if matching_student not in tutor.active_tutorship_students]

        serialized_tutors = serializers.TutorSerializer(
            matching_tutors, many=True)
        res = {
            'num_results': len(matching_tutors),
            'tutors': serialized_tutors.data,
        }
        print(f'Returning res {res}')
        return HttpResponse(JSONRenderer().render(res), content_type='application/json', status=status.HTTP_200_OK)


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
        print(data)

        try:
            subjects = data['tutorship_subjects'].split(',')
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        data['tutorship_subjects'] = subjects

        serializer = serializers.TutorshipSerializer(data=data)

        if (serializer.is_valid()):
            serializer.save()
            res = JSONRenderer().render(serializer.data)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_201_CREATED)
        else:
            print(serializer.errors)
            return HttpResponse(serializer.errors, content_type='application/json', status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, *args, **kwargs):
        data = request.data
        tutorship_id = data.get('id', None)
        tutorship_status = data.get('status', None)
        if not tutorship_id or not tutorship_status:
            return HttpResponse(status=status.HTTP_400_BAD_REQUEST)
        try:
            tutorship = Tutorship.objects.get(id=tutorship_id)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)

        try:
            subjects = data['tutorship_subjects'].split(',')
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        data['tutorship_subjects'] = subjects

        serializer = serializers.TutorshipSerializer(
            tutorship, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            res = JSONRenderer().render(serializer.data)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
        else:
            return HttpResponse(serializer.errors, content_type='application/json', status=status.HTTP_400_BAD_REQUEST)


class MyTutorshipsView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        print(data)
        tutor_uuid = data.get('tutor_uuid', None)
        print(tutor_uuid)
        if not tutor_uuid:
            return HttpResponse(status=status.HTTP_400_BAD_REQUEST)
        try:
            tutor = Tutor.objects.get(uuid=tutor_uuid)
        except Exception as e:
            print(e)
            print('Could not find tutor')
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)
        tutorships = Tutorship.objects.filter(
            tutor=tutor,
            status='PNDG'
        )
        serialized_tutorships = serializers.TutorshipSerializer(
            tutorships, many=True)
        res = {
            'num_results': len(tutorships),
            'tutorships': serialized_tutorships.data
        }
        return HttpResponse(JSONRenderer().render(res), content_type='application/json', status=status.HTTP_200_OK)


class JoinSchoolView(APIView):
    def get(self, request, format=None):
        data = request.query_params
        print(f'Got data {data}')
        join_code = data.get('join_code', None)
        if not join_code:
            return HttpResponse(status=status.HTTP_400_BAD_REQUEST)
        try:
            school = School.objects.get(join_code=join_code)
            print('Got school')
            serialized_school = serializers.SchoolSerializer(school)
            res = JSONRenderer().render(serialized_school.data)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error {e}")
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
            serialized_student = serializers.StudentSerializer(student)
            res = JSONRenderer().render(serialized_student.data)
            return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)
        except:
            return HttpResponse(status=status.HTTP_404_NOT_FOUND)


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
