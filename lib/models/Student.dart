import 'School.dart';
import 'platform_user.dart';

class Student extends PlatformUser {
  final School school;
  final String board;
  final String grade;

  const Student({
    required super.firstName,
    required super.lastName,
    required this.school,
    required this.board,
    required this.grade,

    // required super.account,
    required super.accountId,
    required super.uuid,
    required super.city,
    required super.languages,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['first_name'],
      lastName: json['last_name'],
      school: School.fromJson(json['school']),
      board: json['board'],
      grade: json['grade'],
      accountId: json['account__id'],
      uuid: json['uuid'],
      city: json['city'],
      languages: (json['languages'] as List).map((language) => language as String).toList(),
    );
  }
}
