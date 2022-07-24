import 'package:shared_preferences/shared_preferences.dart';

void upDateSharedPreferences(String token, int id) async {
  print('Updating shared preferences');
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString('token', token);
  _prefs.setInt('id', id);

  _prefs = await SharedPreferences.getInstance();
  var tokenNew = _prefs.get('token');
  var idNew = _prefs.get('id');
  print('New values: $tokenNew, $idNew');
}

// Future<bool> isLoggedIn() {
//   SharedPreferences.getInstance().then((prefs) {
//     var token = prefs.getString('token');
//     var id = prefs.getInt('id');
//     print('Token $token');
//     print("id $id");
//     if (token != null && id != null) {
//       // print('Found string ${token} and int ${id}');
//       return true;
//     } else {
//       return false;
//     }
//   });
//   return false;
// }
