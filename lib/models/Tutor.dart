import 'platform_user.dart';

class Tutor extends PlatformUser {

  List<String> grades = [];
  List<String> boards = [];
  List<String> subjects = [];

  Tutor({
    required this.grades,
    required this.boards,
    required this.subjects,

    required super.account,
    required super.uuid,
    required super.city,
    required super.languages,
  });

}