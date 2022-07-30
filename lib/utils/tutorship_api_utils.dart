// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sih_app/models/platform_user.dart';

import 'package:sih_app/models/account.dart';
import 'package:sih_app/models/School.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/tutorship.dart';

import 'base_api_utils.dart';
import 'accounts_api_utils.dart' as accounts_api_utils;

Future<Tutorship> createTutorship(
    Tutor tutor, Student student, String status) async {
  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  var request = http.Request('POST', Uri.parse('$ROOT_URL/api/tutorships'));
  request.bodyFields = {
    'tutor__uuid': tutor.uuid,
    'student__uuid': student.uuid,
    'status': status
  };
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode != 201) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  return Tutorship.fromJson(body);
}

Future<Tutorship> updateTutorshipStatus(
    String newStatus, int tutorshipId) async {
  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  var request = http.Request('PATCH', Uri.parse('$ROOT_URL/api/tutorships'));
  request.bodyFields = {'id': tutorshipId.toString(), 'status': newStatus};
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode != 200) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  return Tutorship.fromJson(body);
}

Future<Tutorship> getTutorshipFromId(int id) async {
  var request =
      http.Request('GET', Uri.parse('$ROOT_URL/api/tutorships?id=$id'));

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode != 200) {
    print(response.reasonPhrase);
    throw Exception(body);    
  }

  return Tutorship.fromJson(body);
}
