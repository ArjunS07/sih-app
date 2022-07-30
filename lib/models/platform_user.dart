import 'dart:html';

import 'account.dart';
import 'package:sih_app/utils/accounts_api_utils.dart' as accounts_api_utils;

class PlatformUser {
  final String firstName;
  final String lastName;
  final int accountId;
  final String uuid;
  final String city;
  final List<String> languages;

  const PlatformUser(
      {required this.firstName,
      required this.lastName,
      required this.accountId,
      required this.uuid,
      required this.city,
      required this.languages});

  String get profileImageS3Path {
    return 's3_url/profile_images/$uuid.jpg';
  }

  Future<Account> get account async {
    var account = await accounts_api_utils.getAccountFromId(accountId);
    return account;
  }

    
  String get name {
    return firstName + lastName;
  }
}
