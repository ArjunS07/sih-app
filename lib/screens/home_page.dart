import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;

import 'package:sih_app/screens/welcome.dart';

class HomePage extends StatefulWidget {
  
  HomePage({Key? key}) : super(key: key);

  @override
  
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  void logOut() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  prefs.remove('id');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Logged in'),
      ),
      body: Center(child: ElevatedButton(
        child: Text('Log out'),
        onPressed: () => {
          logOut(),
          print('Logged out, going to welcome page'),
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()))
        },
      ))
    );
  
  }
}