import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sih_app/models/platform_user.dart';

import 'package:sih_app/utils/accounts_api_utils.dart' as auth_api_utils;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sih_app/models/account.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutor.dart';

import 'tutorship_charts.dart';
import 'settings.dart';
import 'tutor_search.dart';
import 'tutor_requests.dart';

class BottomTabController extends StatefulWidget {
  final SharedPreferences prefs;

  BottomTabController({Key? key, required this.prefs}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  int _index = 0;

  PlatformUser? loggedInUser;
  bool isStudent = false;

  Future<Account?> _loadLoggedinAccountFromPrefs() async {
    int? id = widget.prefs.getInt('id');
    print('Prefs id: $id');
    if (id != null) {
      var account = await auth_api_utils.getAccountFromId(id);
      print('Got account from prefs id: $account');
      return account;
    }
    return null;
  }

  Future<PlatformUser?> _loadLoggedinUserFromAccount() async {
    var account = await _loadLoggedinAccountFromPrefs();
    if (account != null) {
      var user = await auth_api_utils.getUserFromAccount(account);
      print('Got user from account: $user');
      return user;
    } else {
      print("Error finding user for logged in account");
      return null;
    }
  }

  void setUpUserState() async {
    var user = await _loadLoggedinUserFromAccount();
    if (user != null) {
      setState(() {
        print('Setting state...');
        loggedInUser = user;
        isStudent = user is Student;
        print('Logged in user: $loggedInUser');
        print('Is student: $isStudent');
      });
    }
  }

  @override
  void initState() {
    setUpUserState();
    print('Is student: $isStudent');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = TutorshipChats();
    if (isStudent) {
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Tutors"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
    } else {
      switch (_index) {
        case 0:
          child = TutorshipChats();
          break;
        case 1:
          child = TutorRequests();
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Requests"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
    }


    
  }
}
