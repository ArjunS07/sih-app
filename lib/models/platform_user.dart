

import 'account.dart';
import 'package:sih_app/utils/accounts_api_utils.dart' as accounts_api_utils;
import 'package:sih_app/utils/choices.dart';

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
    return '$firstName $lastName';
  }

  Future<String> get decodedCity async {
    return await decodeChoice(city, 'cities');
  }


  Future<String> getDecodedListMessage(List<String> property, String choiceType) async {
    print('Decoding for $choiceType');
    String joined = '';
    property.asMap().entries.map((entry) async {
      int index = entry.key;
      String val = entry.value;
      String decodedVal = await decodeChoice(val, choiceType);
      print(decodedVal);
      if (index != property.length -1 ) {
        joined = '$joined, $decodedVal';
      } else {
        joined = '$joined and $decodedVal';
      }
    });
    print(joined);
    return joined;
  }

  Future<String> get decodedLanguagesList async {
    return getDecodedListMessage(languages, 'languages');
  }
}
