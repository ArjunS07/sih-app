import 'package:sih_app/utils/choices.dart';

import 'platform_user.dart';

class Tutor extends PlatformUser {
  List<String> grades = [];
  List<String> boards = [];
  List<String> subjects = [];

  int age;
  String highestEducationalLevel;

  Tutor(
      {required super.firstName,
      required super.lastName,
      required super.accountId,
      required super.uuid,
      required super.city,
      required super.languages,
      required this.grades,
      required this.boards,
      required this.subjects,
      required this.age,
      required this.highestEducationalLevel});

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
        firstName: json['account__first_name'],
        lastName: json['account__last_name'],
        grades:
            (json['grades'] as List).map((grade) => grade as String).toList(),
        boards:
            (json['boards'] as List).map((board) => board as String).toList(),
        subjects: (json['subjects'] as List)
            .map((subject) => subject as String)
            .toList(),
        accountId: json['account__id'],
        uuid: json['uuid'],
        city: json['city'],
        languages: (json['languages'] as List)
            .map((language) => language as String)
            .toList(),
        age: json['age'],
        highestEducationalLevel: json['highest_educational_level']);
  }

  Future<String?> get decodedGrades async {
    final displayed = displayListProperty(grades, 'grades');
    // print('Got grades');
    return displayed;
  }

  Future<String?> get decodedSubjects async {
    final displayed = displayListProperty(subjects, 'subjects');
    // print('Got subjects');
    return displayed;
  }

  Future<String?> get decodedBoards async {
    final displayed = displayListProperty(boards, 'boards');
    // print('Got boards');
    return displayed;
  }

  Future<String?> get decodedHighestEducationalLevel async {
    final displayed = decodeChoice(highestEducationalLevel, 'educational_level');
    // print('Got educational level');
    return displayed;
  }
}
