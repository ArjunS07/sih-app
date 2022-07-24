import 'package:shared_preferences/shared_preferences.dart';

void upDateSharedPreferences(String token, int id) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString('token', token);
  _prefs.setInt('id', id);
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();

// Try reading data from the counter key. If it doesn't exist, return 0.
  final token = prefs.get('token');
  final id = prefs.get('id');

  if (token != null && id != null) {
    return true;
  }

  return false;
}

Future<bool> logOut() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  prefs.remove('id');
  return true;
}
