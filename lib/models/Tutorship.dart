import 'package:sih_app/utils/extensions/date_time_extension.dart';
import 'student.dart';
import 'tutor.dart';
import 'package:sih_app/utils/choices.dart';

class Tutorship {
  final int id;
  final Student student;
  final Tutor tutor;
  String status = 'PNDG';
  List<String> subjects;
  final DateTime createdTime; // iso 8601 native datetime
  final String zoomMeetingId;

  Tutorship(
      {required this.id,
      required this.student,
      required this.tutor,
      required this.status,
      required this.subjects,
      required this.createdTime,
      required this.zoomMeetingId});

  factory Tutorship.fromJson(Map<String, dynamic> json) {
    print('Received json $json');
    return Tutorship(
        id: json['id'],
        student: Student.fromJson(json['student']),
        tutor: Tutor.fromJson(json['tutor']),
        subjects: (json['tutorship_subjects'] as List)
            .map((subject) => subject as String)
            .toList(),
        status: json['status'],
        createdTime: DateTime.parse(json['created']),
        zoomMeetingId: json['zoom_meeting__meeting_id']);
  }

  String get relativeTimeSinceCreated {
    return createdTime.timeAgo();
  }

  Future<String> displayListProperty(List property, String type) async {
    if (property.length == 1) {
      String? decodedProperty = await decodeChoice(property[0], type);
      if (decodedProperty != null) {
        return '${decodedProperty}';
      }
    }
    // https://stackoverflow.com/questions/38015671/asynchronous-iterable-mapping-in-dart
    List decodedProperty = await Future.wait(
        property.map((property) async => await decodeChoice(property, type)));
    String message =
        decodedProperty.sublist(0, decodedProperty.length - 1).join(', ');
    message = '$message and ${decodedProperty[decodedProperty.length - 1]}';
    return message;
  }

  Future<String?> get decodedSubjectsDisplay async {
    return displayListProperty(subjects, 'subjects');
  }
}
