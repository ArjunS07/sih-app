import 'package:shared_preferences/shared_preferences.dart';

void upDateSharedPreferences(String token, int id) async {
  print('Updating shared preferences');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
  prefs.setInt('id', id);

  prefs = await SharedPreferences.getInstance();
  var tokenNew = prefs.get('token');
  var idNew = prefs.get('id');
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
