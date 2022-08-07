import 'package:sih_app/utils/choices.dart';

class School {
  final int accountId;
  final String name;
  final String city;
  final String joinCode;

  const School({
    required this.accountId,
    required this.name,
    required this.city,
    required this.joinCode,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      accountId: json['account__id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      joinCode: json['join_code'] as String,
    );
  }

  Future<String?> get decodedCity async {
    return await decodeChoice(city, 'cities');
  }

}