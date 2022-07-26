// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih_app/main.dart';
import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;


class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void logOut(context) async {
    final prefs = await SharedPreferences.getInstance();
    print('Removing token and id');
    prefs.remove('token');
    prefs.remove('id');
    persistence_utils.getPrefs().then((prefs) => {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) {
              return MyApp(prefs: prefs);
            },
          ), (route) => false)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You are logged in!',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              child: const Text('Log out'),
              onPressed: () => logOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
