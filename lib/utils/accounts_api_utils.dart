// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sih_app/models/platform_user.dart';
import 'package:uuid/uuid.dart';

import 'package:sih_app/models/account.dart';
import 'package:sih_app/models/School.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutor.dart';

final String ROOT_URL = 'http://localhost:8000';
Uuid uuid = const Uuid();

Future<String> getAccountAuthToken(String email, String password) async {
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  var request =
      http.Request('POST', Uri.parse('$ROOT_URL/accounts/api-token-auth/'));
  request.bodyFields = {
    'username':
        email, //the api requires a username field but we're using an email so it works
    'password': password
  };
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode == 200) {
    return body['token'];
  } else {
    throw Exception('Failed to get token');
  }
}

Future<Account?> login(String email, String password) async {
  final loginUri = Uri.parse('$ROOT_URL/accounts/login/');

  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  var request = http.Request('POST', loginUri);
  request.bodyFields = {'email': email, 'password': password};
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode != 200) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  Map<String, dynamic> accountInfo = body['user'];
  var account = Account.fromJson(accountInfo);
  account.authToken = await getAccountAuthToken(email, password);
  return account;
}

Future<Account?> registerNewAccount(
    String email, String password, String firstName, String lastName) async {
  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  final registerUri = Uri.parse('$ROOT_URL/accounts/register/');
  var request = http.Request('POST', registerUri);
  request.bodyFields = {
    'email': email,
    'password1': password,
    'password2': password,
    'first_name': firstName,
    'last_name': lastName
  };
  request.headers.addAll(headers);
  print(request);
  print(request.bodyFields);
  print(request.headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode == 201) {
    var accountData = body['user'];
    var account = Account.fromJson(accountData);
    account.authToken = await getAccountAuthToken(email, password);
    return account;
  } else {
    print(response.reasonPhrase);
    throw Exception(body);
  }
}

Future<Student?> createStudent(
    Account account,
    String city,
    List<String> languages,
    School studentSchool,
    String board,
    String grade) async {
  // 1. Make an API call to create a student account
  final String parsedLanguages = languages.join(',');
  final String studentUuid = uuid.v4();

  final Uri studentCreationUri = Uri.parse('$ROOT_URL/api/student');
  var studentCreationHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  var studentCreationRequest = http.Request('POST', studentCreationUri);
  studentCreationRequest.bodyFields = {
    'account__id': account.accountId.toString(),
    'city': city,
    'languages': parsedLanguages,
    'board': board,
    'grade': grade,
    'uuid': studentUuid
  };
  studentCreationRequest.headers.addAll(studentCreationHeaders);
  print(studentCreationRequest.bodyFields);
  print(studentCreationRequest.headers);

  http.StreamedResponse studentCreationResponse =
      await studentCreationRequest.send();
  Map<String, dynamic> studentCreationBody =
      json.decode(await studentCreationResponse.stream.bytesToString());

  if (studentCreationResponse.statusCode != 201) {
    print(studentCreationResponse.reasonPhrase);
    throw Exception(studentCreationBody);
  }

  // 2. Make the student join the school
  final Uri joinSchoolUri = Uri.parse('$ROOT_URL/api/joinschool');
  var joinSchoolRequest = http.Request('POST', joinSchoolUri);

  var joinSchoolheaders = {'Content-Type': 'application/x-www-form-urlencoded'};
  joinSchoolRequest.bodyFields = {
    'join_code': studentSchool.joinCode,
    'student_uuid': studentUuid
  };
  joinSchoolRequest.headers.addAll(joinSchoolheaders);

  http.StreamedResponse joinSchoolResponse = await joinSchoolRequest.send();
  Map<String, dynamic> joinSchoolBody =
      json.decode(await joinSchoolResponse.stream.bytesToString());

  if (joinSchoolResponse.statusCode != 200) {
    print(joinSchoolResponse.reasonPhrase);
    print(joinSchoolResponse.reasonPhrase);
    print(joinSchoolBody);
    throw Exception(joinSchoolBody);
  }

  print('Joined student to school');

  Student student = Student(
      account: account,
      city: city,
      languages: languages,
      school: studentSchool,
      board: board,
      grade: grade,
      uuid: studentUuid);

  return student;
}

Future<Tutor> createTutor(Account account, String city, List<String> languages,
    List<String> boards, List<String> grades, List<String> subjects) async {
  final String parsedLanguages = languages.join(',');
  final String parsedBoards = boards.join(',');
  final String parsedGrades = grades.join(',');
  final String parsedSubjects = subjects.join(',');
  final String tutorUuid = uuid.v4();

  final Uri tutorCreationUri = Uri.parse('$ROOT_URL/api/tutor');
  var headers = {
    'Authorization':
        'Token ${account.authToken}', // authorization header requires this formatting
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  var request = http.Request('POST', tutorCreationUri);
  request.bodyFields = {
    'uuid': tutorUuid,
    'city': city,
    'languages': parsedLanguages,
    'boards': parsedBoards,
    'subjects': parsedSubjects,
    'grades': parsedGrades,
    'account__id': account.accountId.toString()
  };
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  if (response.statusCode != 201) {
    print(response.reasonPhrase);
    throw Exception(body);
  }

  Tutor tutor = Tutor(
      account: account,
      city: city,
      languages: languages,
      boards: boards,
      grades: grades,
      subjects: subjects,
      uuid: tutorUuid);
  return tutor;
}

Future<Account> getAccountFromId(int id) async {
  final Uri getAccountUri = Uri.parse('$ROOT_URL/accounts/users?id=$id');
  var request = http.Request('GET', getAccountUri);

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode == 200) {
    Account account = Account.fromJson(body);
    return account;
  } else {
    throw (response.reasonPhrase.toString());
  }
}

Future<PlatformUser> getUserFromAccount(Account account) async {
  int id = account.accountId;
  var request = http.Request(
      'GET', Uri.parse('$ROOT_URL/api/userfromaccount?account_id=$id'));

  http.StreamedResponse response = await request.send();
  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());

  if (response.statusCode == 200) {
    bool isStudent = body['type'] == 'student';
    print(body);
    Map<String, dynamic> userDetails = body['user'];
    if (isStudent) {
      List<String> languages = userDetails['languages'].cast<String>();
      Student student = Student(
        account: account,
        city: userDetails['city'],
        languages: languages,
        school: School.fromJson(userDetails['school']),
        grade: userDetails['grade'],
        board: userDetails['board'],
        uuid: userDetails['uuid'],
      );
      return student;
    } else {
      List<String> languages = userDetails['languages'].cast<String>();
      List<String> boards = userDetails['boards'].cast<String>();
      List<String> grades = userDetails['grades'].cast<String>();
      List<String> subjects = userDetails['subjects'].cast<String>();
      Tutor tutor = Tutor(
        account: account,
        city: userDetails['city'],
        languages: languages,
        boards: boards,
        grades: grades,
        subjects: subjects,
        uuid: userDetails['uuid'],
      );
      return tutor;
    }
  } else {
    throw (response.reasonPhrase.toString());
  }
}
