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

Future<List<Tutor>> loadTutorsFromParams(
    {List<String>? languages,
    List<String>? grades,
    List<String>? boards,
    List<String>? subjects}) async {
  Map<String, String> queryParams = {};
  if (languages != null && languages.isNotEmpty) {
    queryParams['languages'] = languages.join(',');
  }
  if (grades != null && grades.isNotEmpty) {
    print('Sending grades $grades in get request...');
    queryParams['grades'] = grades.join(',');
  }
  if (boards != null && boards.isNotEmpty) {
    queryParams['boards'] = boards.join(',');
  }
  if (subjects != null && subjects.isNotEmpty) {
    print('Received subjects $subjects');
    String joined = subjects.join(',');
    print('Joined subjects $joined');
    queryParams['subjects'] = joined;
  }

  var headers = {'Content-Type': 'application/json'};
  final tutorSearchUri =
      Uri.parse('$ROOT_URL/api/tutorslist').replace(queryParameters: queryParams);
  print(tutorSearchUri);

  var request = http.Request('GET', tutorSearchUri);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  print('Sending request...');
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  print('Got body $body');

  if (response.statusCode != 200) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  int numResults = body['num_results'];

  List<Tutor> tutors = (body['tutors'] as List).map((tutor) {
    return Tutor.fromJson(tutor);
  }).toList();

  return tutors;
}