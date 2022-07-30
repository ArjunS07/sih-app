import 'package:sih_app/utils/accounts_api_utils.dart';

import 'platform_user.dart';

import 'account.dart';
class Tutor extends PlatformUser {

  List<String> grades = [];
  List<String> boards = [];
  List<String> subjects = [];

  Tutor({
    required super.firstName,
    required super.lastName,

    required this.grades,
    required this.boards,
    required this.subjects,

    required super.accountId,
    required super.uuid,
    required super.city,
    required super.languages,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      firstName: json['first_name'],
      lastName: json['last_name'],
      grades: (json['grades'] as List).map((grade) => grade as String).toList(),
      boards: (json['boards'] as List).map((board) => board as String).toList(),
      subjects: (json['subjects'] as List).map((subject) => subject as String).toList(),
      accountId: json['account__id'],
      uuid: json['uuid'],
      city: json['city'],
      languages: (json['languages'] as List).map((language) => language as String).toList(),
    );
  }


}