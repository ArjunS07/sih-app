// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sih_app/models/platform_user.dart';

import 'package:sih_app/models/account.dart';
import 'package:sih_app/models/School.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutor.dart';

import 'base_api_utils.dart';
import 'accounts_api_utils.dart' as accounts_api_utils;

Future<School?> getSchoolFromJoinCode(String joinCode) async {
  final uri = Uri.parse('$ROOT_URL/api/joinschool?join_code=${joinCode}');
  final response = await http.get(uri);
  final code = response.statusCode;
  if (code == 404) {
    return null;
  }
  final json = jsonDecode(response.body);
  final school = School.fromJson(json);
  print(school);
  return school;
}

Future<Student> joinStudentToSchool(
    String studentUuid, String schoolJoinCode) async {
  final Uri joinSchoolUri = Uri.parse('$ROOT_URL/api/joinschool');
  var joinSchoolRequest = http.Request('POST', joinSchoolUri);

  var joinSchoolheaders = {'Content-Type': 'application/x-www-form-urlencoded'};
  joinSchoolRequest.bodyFields = {
    'join_code': schoolJoinCode,
    'student_uuid': studentUuid
  };
  joinSchoolRequest.headers.addAll(joinSchoolheaders);

  http.StreamedResponse joinSchoolResponse = await joinSchoolRequest.send();
  Map<String, dynamic> joinSchoolBody =
      json.decode(await joinSchoolResponse.stream.bytesToString());

  if (joinSchoolResponse.statusCode != 200) {
    print(joinSchoolResponse.reasonPhrase);
    throw Exception(joinSchoolBody);
  }
  Student student = Student.fromJson(joinSchoolBody);
  return student;
}

Future<Student> updateStudentDetails(Student student,
    {String? grade,
    String? board,
    String? schoolJoinCode,
    List? languages,
    String? city}) async {
  Map<String, String> queryParams = {'uuid': student.uuid};
  if (grade != null) {
    queryParams['grade'] = grade;
  }
  if (board != null) {
    queryParams['board'] = board;
  }

  if (languages != null && languages.isNotEmpty) {
    queryParams['languages'] = languages.join(',');
  }
  if (city != null) {
    queryParams['city'] = city;
  }

  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  var request = http.Request('PATCH',
      Uri.parse('$ROOT_URL/api/tutors').replace(queryParameters: queryParams));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  if (response.statusCode != 200) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  if (schoolJoinCode != null) {
    return await joinStudentToSchool(student.uuid, schoolJoinCode);
  }

  return Student.fromJson(body);
}
