import 'package:sih_app/utils/extensions/date_time_extension.dart';


class Tutorship {
  final int id;
  final String studentUuid;
  final String tutorUuid;
  String status = 'PNDG';
  final DateTime createdTime; // iso 8601 native datetime

  Tutorship(
      {required this.id,
      required this.studentUuid,
      required this.tutorUuid,
      required this.status, required this.createdTime});

  factory Tutorship.fromJson(Map<String, dynamic> json) {
    return Tutorship(
      id: json['id'],
      studentUuid: json['student']['uuid'],
      tutorUuid: json['tutor']['uuid'],
      status: json['status'],
      createdTime: DateTime.parse(json['created'])
    );
  }

  String get relativeTimeSinceCreated {
    return createdTime.timeAgo(numericDates: false);
  }

}
