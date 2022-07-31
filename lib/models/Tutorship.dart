import 'package:sih_app/utils/extensions/date_time_extension.dart';
import 'student.dart';
import 'tutor.dart';

class Tutorship {
  final int id;
  final Student student;
  final Tutor tutor;
  String status = 'PNDG';
  List<String> subjects;
  final DateTime createdTime; // iso 8601 native datetime

  Tutorship(
      {required this.id,
      required this.student,
      required this.tutor,
      required this.status,
      required this.subjects,
      required this.createdTime});

  factory Tutorship.fromJson(Map<String, dynamic> json) {
    return Tutorship(
        id: json['id'],
        student: Student.fromJson(json['student']),
        tutor: Tutor.fromJson(json['tutor']),
        subjects: (json['subjects'] as List).map((subject) => subject as String).toList(),
        status: json['status'],
        createdTime: DateTime.parse(json['created']));
  }

  String get relativeTimeSinceCreated {
    return createdTime.timeAgo(numericDates: false);
  }
}
