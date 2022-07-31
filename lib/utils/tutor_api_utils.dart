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
    [List<String>? languages,
    List<String>? grades,
    List<String>? boards,
    List<String>? subjects]) async {
  Map<String, String> queryParams = {};
  if (languages != null) {
    queryParams = {'languages': languages.join(',')};
  }
  if (grades != null) {
    queryParams = {'grades': grades.join(',')};
  }
  if (boards != null) {
    queryParams = {'boards': boards.join(',')};
  }
  if (subjects != null) {
    queryParams = {'subjects': subjects.join(',')};
  }

  var headers = {'Content-Type': 'application/json'};
  final tutorSearchUri =
      Uri.parse('$ROOT_URL/api/tutorslist').replace(queryParameters: queryParams);

  var request = http.Request('GET', tutorSearchUri);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  print('Sending requeust...');
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