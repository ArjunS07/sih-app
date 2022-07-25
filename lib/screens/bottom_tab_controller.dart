import 'package:flutter/material.dart';

import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;
import 'package:shared_preferences/shared_preferences.dart';

import 'tutorship_charts.dart';
import 'settings.dart';
import 'tutor_search.dart';
import 'welcome.dart';

class BottomTabController extends StatefulWidget {
  final SharedPreferences prefs;

  BottomTabController({Key? key, required this.prefs}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  int index = 0;

  bool _isLoggedIn() {
    return widget.prefs.get('token') != null;
  }

  Widget _decideWidget(context) {
    print(widget.prefs.get('token'));
    if (widget.prefs.get('token') != null && widget.prefs.get('id') != null) {
      print('Found token and id while navigating to tab bar');
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
                  child: MaterialApp(home: TutorshipChats()))),
          Offstage(
              offstage: index != 1,
              child: TickerMode(
                enabled: index == 1,
                child: MaterialApp(home: TutorSearch()),
              )),
          Offstage(
              offstage: index != 2,
              child: TickerMode(
                  enabled: index == 2,
                  child: MaterialApp(home: Settings()))),
        ]),
        bottomNavigationBar: Visibility(
          visible: _isLoggedIn(),
          child: BottomNavigationBar(
              currentIndex: index,
              onTap: (int index) {
                setState(() {
                  this.index = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tutors'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ]),
        ),
      );
    } else {
      return WelcomePage();
    }
  }

int _index = 0;

@override
Widget build(BuildContext context) {
  Widget child = TutorshipChats();
  switch (_index) {
    case 0:
      child = TutorshipChats();
      break;
    case 1:
      child = TutorSearch();
      break;
    case 2:
      child = Settings();
      break;
  }

  return Scaffold(
    body: SizedBox.expand(child: child),
    bottomNavigationBar: BottomNavigationBar(
      onTap: (newIndex) => setState(() => _index = newIndex),
      currentIndex: _index,
      items: const <BottomNavigationBarItem> [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tutors"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    ),
  );
}


}
