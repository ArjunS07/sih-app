import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:sih_app/screens/welcome.dart';
import 'package:sih_app/screens/bottom_tab_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((value) => {runApp(MyApp(prefs: prefs))});
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  _decideMainPage() {
    if (prefs.get('token') != null && prefs.get('id') != null) {
      return BottomTabController(
        prefs: prefs,
      );
    } else {
      return WelcomePage();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.white,
          ),
        ),
        home: _decideMainPage());
  }
}
