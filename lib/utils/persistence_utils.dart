import 'package:shared_preferences/shared_preferences.dart';

void upDateSharedPreferences(String token, int id) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString('token', token);
  _prefs.setInt('id', id);
}