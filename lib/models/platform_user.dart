import 'account.dart';

class PlatformUser {
  final Account account;
  final String uuid;
  final String city;
  final List<String> languages;

  const PlatformUser({
    required this.account,
    required this.uuid,
    required this.city,
    required this.languages,
  });

  String get profileImageS3Path {
    return 's3_url/profile_images/$uuid.jpg';
  }

}