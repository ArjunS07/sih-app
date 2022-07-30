import 'tutor.dart';
import 'student.dart';

class Tutorship {
  final int id;
  final String studentUuid;
  final String tutorUuid;
  String status = 'PNDG';

  Tutorship(
      {required this.id,
      required this.studentUuid,
      required this.tutorUuid,
      required this.status});

  factory Tutorship.fromJson(Map<String, dynamic> json) {
    return Tutorship(
      id: json['id'],
      studentUuid: json['student_uuid'],
      tutorUuid: json['tutor_uuid'],
      status: json['status'],
    );
  }
}
