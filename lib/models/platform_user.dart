import 'account.dart';
import 'package:sih_app/utils/accounts_api_utils.dart' as accounts_api_utils;
import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/utils/extensions/list_extension.dart';
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

  String get profileImageUrl {
    return '/profile_images/$uuid.jpg';
  }

  Future<Account> get account async {
    var account = await accounts_api_utils.getAccountFromId(accountId);
    return account;
  }

  String get name {
    return '$firstName $lastName';
  }

  Future<String?> get decodedCity async {
    return await decodeChoice(city, 'cities');
  }

  Future<String> displayListProperty(List property, String type) async {
    // https://stackoverflow.com/questions/38015671/asynchronous-iterable-mapping-in-dart
    List decodedProperty = await Future.wait(
        property.map((property) async => await decodeChoice(property, type)));
    return decodedProperty.joinedWithAnd();
  }

  Future<String?> get decodedLanguagesDisplay async {
    return displayListProperty(languages, 'languages');
  }
}
