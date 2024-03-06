// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart' as settings_ui;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';

import 'package:sih_app/main.dart';

import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;
import 'package:sih_app/utils/extensions/list_extension.dart';

import 'package:sih_app/models/platform_user.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutor.dart';

import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/models/choice.dart';

class Settings extends StatefulWidget {
  final Function() notifyParentReload;
  Tutor? loggedInTutor;
  Student? loggedInStudent;

  Settings(
      {Key? key,
      required this.notifyParentReload,
      this.loggedInStudent,
      this.loggedInTutor})
      : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool _isLoggedInStudent;
  late PlatformUser _loggedInUser;

  // Account update info
  String? _newFirstName;
  String? _newLastName;

  // Generic user info
  String? _newCityId;
  List<String> _newLanguages = [];

  // Student info
  String? _newBoardId;
  String? _newGradeId;

  // Tutor info
  List<String> _newBoardIds = [];
  List<String> _newGradeIds = [];
  List<String> _newSubjectIds = [];

  // Choices
  late List<Choice> _languageChoices = [];
  late List<Choice> _boardChoices = [];
  late List<Choice> _cityChoices = [];
  late List<Choice> _gradeChoices = [];
  late List<Choice> _subjectChoices = [];

  // Display lists
  late List<String> _languagesDispl = [];
  late List<String> _boards = [];
  late List<String> _gradesDispl = [];
  late List<String> _subjectsDispl = [];
  late List<String> _cities = [];

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

  void getChoices() async {
    _languageChoices = await loadChoices('languages');
    _boardChoices = await loadChoices('boards');
    _cityChoices = await loadChoices('cities');
    _gradeChoices = await loadChoices('grades');
    _subjectChoices = await loadChoices('subjects');

    setState(() {
      _languageChoices = _languageChoices;
      _boardChoices = _boardChoices;
      _cityChoices = _cityChoices;
      _gradeChoices = _gradeChoices;
      _subjectChoices = _subjectChoices;
    });
    // _languageChoices = await getChoicesMap('languages').values.toList();
    // _cityChoices = await getChoicesMap('cities');
    // _gradeChoices = await getChoicesMap('grades');
  }

  @override
  void initState() {
    super.initState();
    if (widget.loggedInStudent != null) {
      setState(() {
        _isLoggedInStudent = true;
        _loggedInUser = widget.loggedInStudent as Student;
      });
    } else {
      setState(() {
        _isLoggedInStudent = false;
        _loggedInUser = widget.loggedInTutor as Tutor;
      });
    }
    getChoices();
  }

  // Popup components
  _languageMultiSelectDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialogField(
              buttonText: Text(
                'Select languages',
                style: TextStyle(fontSize: 16.0, color: Colors.grey.shade900),
              ),
              buttonIcon: const Icon(Icons.language),
              title: const Text('Your languages'),
              selectedColor: Colors.black,
              searchable: true,
              items: _languageChoices
                  .map(
                      (language) => MultiSelectItem(language.id, language.name))
                  .toList(),
              listType: MultiSelectListType.LIST,
              initialValue: _loggedInUser.languages,
              onConfirm: (values) {
                for (var value in values) {
                  _newLanguages.add(value.toString());
                }
              });
        });
  }

  // Tutor dialogs
  _boardsMultiSelectDialog(Tutor tutor) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
              initialValue: tutor.boards,
              title: const Text('Your boards'),
              selectedColor: Colors.black,
              searchable: true,
              items: _boardChoices
                  .map((board) => MultiSelectItem(board.id, board.name))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                for (var value in values) {
                  _newBoardIds.add(value.toString());
                }
              });
        });
  }

  _gradesMultiSelectDialog(Tutor tutor) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
              initialValue: tutor.boards,
              title: const Text('Grades you teach'),
              selectedColor: Colors.black,
              searchable: true,
              items: _gradeChoices
                  .map((grade) => MultiSelectItem(grade.id, grade.name))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                for (var value in values) {
                  _newGradeIds.add(value.toString());
                }
              });
        });
  }

  settings_ui.AbstractSettingsSection _personalInfoSection() {
    return settings_ui.SettingsSection(
        title: const Text('Personal information'),
        tiles: [
          settings_ui.SettingsTile(
            title: const Text('First name'),
            leading: const Icon(Icons.person),
            value: Text(_loggedInUser.firstName),
          ),
          settings_ui.SettingsTile(
            title: const Text('Last name'),
            leading: const Icon(Icons.person),
            value: Text(_loggedInUser.lastName),
          ),
          settings_ui.SettingsTile(
              leading: Icon(Icons.pin_drop),
              title: const Text('City'),
              value: Text(
                _loggedInUser.city,
              )),
          settings_ui.SettingsTile(
              title: const Text('Languages you speak'),
              leading: const Icon(Icons.language),
              value: Text(
                _loggedInUser.languages.joinedWithAnd(),
              )),
        ]);
  }

  settings_ui.AbstractSettingsSection _studentSettings() {
    Student student = _loggedInUser as Student;

    return settings_ui.SettingsSection(
        title: const Text('Learning information'),
        tiles: [
          settings_ui.SettingsTile(
            title: Text('Board\n${student.board}'),
            leading: const Icon(Icons.school),
            value: Text(student.board),
            // onPressed: ,
          ),
          settings_ui.SettingsTile(
            title: const Text('Grade'),
            leading: const Icon(Icons.menu_book_sharp),
            value: Text(student.grade),
          ),
          settings_ui.SettingsTile(
            title: const Text('School'),
            leading: const Icon(Icons.school),
            value: Text(student.school.name),
          )
        ]);
  }

  settings_ui.AbstractSettingsSection _tutorSettings() {
    return settings_ui.SettingsSection(
        title: const Text('What you teach'),
        tiles: [
          settings_ui.SettingsTile(
            title: const Text('Boards'),
            leading: const Icon(Icons.school),
            description: Text((_loggedInUser as Tutor).boards.joinedWithAnd()),
          ),
          settings_ui.SettingsTile(
            title: const Text('Grades'),
            leading: const Icon(Icons.menu_book_sharp),
            value: Text((_loggedInUser as Tutor).grades.joinedWithAnd()),
          ),
          settings_ui.SettingsTile(
            title: const Text('Subjects'),
            leading: const Icon(Icons.science),
            value: Text((_loggedInUser as Tutor).subjects.joinedWithAnd()),
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          automaticallyImplyLeading: false,
        ),
        body: settings_ui.SettingsList(
          sections: [
            // _personalInfoSection(),
            // _isLoggedInStudent ? _studentSettings() : _tutorSettings(),
            settings_ui.SettingsSection(title: const Text('Account'), tiles: [
              settings_ui.SettingsTile.navigation(
                title: const Text('Sign out'),
                leading: const Icon(Icons.exit_to_app),
                onPressed: logOut,
              ),
            ]),
          ],
        ));
  }
}
