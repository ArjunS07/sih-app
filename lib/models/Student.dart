import 'School.dart';
import 'platform_user.dart';

class Student extends PlatformUser {
  final School school;
  final String board;
  final String grade;


  const Student({
    required this.school,
    required this.board,
    required this.grade,
    
    required super.account,
    required super.uuid,
    required super.city,
    required super.languages,
  });
}