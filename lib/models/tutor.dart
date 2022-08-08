import 'package:sih_app/utils/accounts_api_utils.dart';

import 'platform_user.dart';

class Tutor extends PlatformUser {
  List<String> grades = [];
  List<String> boards = [];
  List<String> subjects = [];

  Tutor({
    required super.firstName,
    required super.lastName,
    required super.accountId,
    required super.uuid,
    required super.city,
    required super.languages,
    required this.grades,
    required this.boards,
    required this.subjects,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      firstName: json['account__first_name'],
      lastName: json['account__last_name'],
      grades: (json['grades'] as List).map((grade) => grade as String).toList(),
      boards: (json['boards'] as List).map((board) => board as String).toList(),
      subjects: (json['subjects'] as List)
          .map((subject) => subject as String)
          .toList(),
      accountId: json['account__id'],
      uuid: json['uuid'],
      city: json['city'],
      languages: (json['languages'] as List)
          .map((language) => language as String)
          .toList(),
    );
  }

  Future<String?> get decodedGrades async {
    return displayListProperty(grades, 'grades');
  }

  Future<String?> get decodedSubjects async {
    return displayListProperty(subjects, 'subjects');
  }

  Future<String?> get decodedBoards async {
    return displayListProperty(boards, 'boards');
  }
}
