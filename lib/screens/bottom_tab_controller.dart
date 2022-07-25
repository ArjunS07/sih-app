import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;

import 'tutorship_charts.dart';
import 'settings.dart';
import 'tutor_search.dart';

class BottomTabController extends StatefulWidget {
  BottomTabController({Key? key}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  void logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('id');
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text('Logged in'),
      // ),
      body: Stack(children: <Widget>[
        Offstage(
            offstage: index != 0,
            child: TickerMode(
                enabled: index == 0,
                child: new MaterialApp(home: TutorshipChats()))),
        Offstage(
            offstage: index != 1,
            child: TickerMode(
              enabled: index == 1,
              child: new MaterialApp(home: TutorSearch()),
            )),
        Offstage(
            offstage: index != 2,
            child: TickerMode(
                enabled: index == 2,
                child: new MaterialApp(home: Settings()))),
      ]),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (int index) {
            setState(() {
              this.index = index;
            });
          },
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Tutors'),
            const BottomNavigationBarItem(icon: const Icon(Icons.search), label: 'Find'),
            const BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'Settings'),
          ]),
    );
  }
}
