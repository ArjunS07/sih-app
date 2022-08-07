// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';

import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;

import 'package:sih_app/models/School.dart';
import 'package:sih_app/utils/accounts_api_utils.dart';
import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/models/choice.dart';
import 'package:sih_app/screens/bottom_tab_controller.dart';
import 'signup.dart';

class JoinSchool extends StatefulWidget {
  JoinSchool({Key? key}) : super(key: key);

  @override
  State<JoinSchool> createState() => _JoinSchoolState();
}

class _JoinSchoolState extends State<JoinSchool> {
  final joinCodeFieldController = TextEditingController();
  var canSubmitJoinCode = false;
  String errorText = '';
  var isLoading = false;

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        width: 100.0,
        height: 100.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Finding your school...')
            ],
          ),
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<School?> _getSchoolFromJoinCode(String joinCode) async {
    final uri =
        Uri.parse('http://localhost:8000/api/joinschool?join_code=${joinCode}');
    final response = await http.get(uri);
    final code = response.statusCode;
    if (code == 404) {
      return null;
    }
    final json = jsonDecode(response.body);
    final school = School.fromJson(json);
    print(school);
    return school;
  }

  void _submitSchoolJoinCode(String joinCode, BuildContext context) {
    if (joinCode == '') {
      return;
    }
    showAlertDialog(context);
    _getSchoolFromJoinCode(joinCode).then((school) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
        if (school != null) {
          print('Joining school ${school.name}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmSchool(school: school),
              ));
        } else {
          setState(() {
            errorText = 'No school found with this join code';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    joinCodeFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    joinCodeFieldController.addListener(() {
      setState(() {
        canSubmitJoinCode = joinCodeFieldController.text.isNotEmpty &&
            joinCodeFieldController.text.length == 6;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your account'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(width: 2, color: Colors.grey.shade400)),
              child: const Image(
                image: AssetImage('assets/images/school.png'),
                width: 75,
                height: 77.985,
              ),
            ),
            const SizedBox(height: 45.0),
            const Text('Enter your school code ',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Text(
                'Your school should have provided you a unique 6-letter code. Ask your school administrators if you do not have it.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400)),
            const SizedBox(height: 45.0),
            TextField(
              controller: joinCodeFieldController,
              onSubmitted: (code) => _submitSchoolJoinCode(code, context),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your school code',
              ),
              keyboardType: TextInputType.visiblePassword,
              enableSuggestions: false,
              autocorrect: false,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                primary: Colors.black,
              ),
              onPressed: canSubmitJoinCode
                  ? () => _submitSchoolJoinCode(
                      joinCodeFieldController.text, context)
                  : null,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 15.0),
            Text(errorText,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade900,
                    fontSize: 16.0)),
          ]),
        ),
      ),
    );
  }
}

class ConfirmSchool extends StatefulWidget {
  final School school;
  const ConfirmSchool({Key? key, required this.school}) : super(key: key);

  @override
  State<ConfirmSchool> createState() => _ConfirmSchoolState();
}

class _ConfirmSchoolState extends State<ConfirmSchool> {
  var schoolCity;

  void loadCity() async {
    final decoded = await widget.school.decodedCity;

    setState(() {
      schoolCity = decoded;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCity();
  }

  @override
  Widget build(BuildContext context) {
    if (schoolCity == null) {
      return const SizedBox(
          width: 100.0, child: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm your school'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Is this your school?',
                    style:
                        TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      border:
                          Border.all(width: 2, color: Colors.grey.shade400)),
                  child: const Image(
                    image: AssetImage('assets/images/school_color.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 35),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    widget.school.name,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  schoolCity,
                  style: const TextStyle(fontSize: 24),
                ),
                const Spacer(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.black,
                    ),
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountSignup(
                                    isStudent: true, school: widget.school),
                              ))
                        },
                    child: const Text('Yes', style: TextStyle(fontSize: 17.0))),
                const SizedBox(height: 10.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.grey.shade700,
                    ),
                    onPressed: () => {Navigator.of(context).pop()},
                    child: const Text('No', style: TextStyle(fontSize: 17.0))),
                const SizedBox(height: 25.0)
              ]),
        ),
      ),
    );
  }
}

class StudentDetails extends StatefulWidget {
  final School school;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  StudentDetails(
      {Key? key,
      required this.school,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.password})
      : super(key: key);

  @override
  State<StudentDetails> createState() => StudentDetailsState();
}

class StudentDetailsState extends State<StudentDetails> {
  late List<Choice> _languageChoices = [];
  late List<String> _selectedLanguagesIds = [];

  late List<Choice> _boardChoices = [];
  late String? _selectedBoardId = null;

  late List<Choice> _cityChoices = [];
  late String? _selectedCityId = null;

  late List<Choice> _gradeChoices = [];
  late String? _selectedGradeId = null;

  void getChoices() async {
    _languageChoices = await loadChoices('languages');
    _boardChoices = await loadChoices('boards');
    _cityChoices = await loadChoices('cities');
    _gradeChoices = await loadChoices('grades');

    setState(() {
      _languageChoices = _languageChoices;
      _boardChoices = _boardChoices;
      _cityChoices = _cityChoices;
      _gradeChoices = _gradeChoices;
    });
    // _languageChoices = await getChoicesMap('languages').values.toList();
    // _cityChoices = await getChoicesMap('cities');
    // _gradeChoices = await getChoicesMap('grades');
  }

  @override
  void initState() {
    getChoices();
    super.initState();
  }

  void _submitRegistration(context) async {
    var account = await registerNewAccount(
            widget.email, widget.password, widget.firstName, widget.lastName)
        .catchError((error) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Error'),
                content: Text('$error'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
      print('Error creating account');
    });
    if (account != null) {
      print('Creating student account');
      persistence_utils.upDateSharedPreferences(
          account.authToken!, account.accountId);

      var student = await createStudent(
              account,
              _selectedCityId!,
              _selectedLanguagesIds,
              widget.school,
              _selectedBoardId!,
              _selectedGradeId!)
          .then((tutor) => {
                persistence_utils.getPrefs().then((prefs) => {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BottomTabController(prefs: prefs)))
                    })
              })
          .catchError((error) {
        print(error);
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('$error'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your details'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('What languages do you speak?',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold))),
                  MultiSelectDialogField(
                      buttonText: Text(
                        'Select languages',
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.grey.shade900),
                      ),
                      buttonIcon: const Icon(Icons.language),
                      title: const Text('Your languages'),
                      selectedColor: Colors.black,
                      searchable: true,
                      items: _languageChoices
                          .map((language) =>
                              MultiSelectItem(language.id, language.name))
                          .toList(),
                      listType: MultiSelectListType.LIST,
                      onConfirm: (values) {
                        for (var value in values) {
                          _selectedLanguagesIds.add(value.toString());
                        }
                      }),
                ]),
                const SizedBox(height: 40.0),
                Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('What city do you live in?',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.grey.shade900))),
                  SearchChoices.single(
                    icon: const Icon(Icons.pin_drop),
                    items: _cityChoices
                        .map((city) => DropdownMenuItem(
                            value: city.id, child: Text(city.name)))
                        .toList(),
                    value: _selectedCityId,
                    padding: 0.0,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                    hint: "Select your city",
                    searchHint: "Select your city",
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                      });
                    },
                    isExpanded: true,
                  )
                ]),
                const SizedBox(height: 40.0),
                Column(children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('What board do you study in?',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold))),
                  SearchChoices.single(
                    icon: const Icon(Icons.school),
                    items: _boardChoices
                        .map((board) => DropdownMenuItem(
                            value: board.id, child: Text(board.name)))
                        .toList(),
                    value: _selectedBoardId,
                    padding: 0.0,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                    hint: "Select your school board",
                    searchHint: "Select your school board",
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _selectedBoardId = value;
                      });
                    },
                    isExpanded: true,
                  )
                ]),
                const SizedBox(height: 40.0),
                Column(children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('What grade do you study in?',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold))),
                  SearchChoices.single(
                    icon: const Icon(Icons.pin),
                    items: _gradeChoices
                        .map((grade) => DropdownMenuItem(
                            value: grade.id, child: Text(grade.name)))
                        .toList(),
                    value: _selectedGradeId,
                    padding: 0.0,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                    hint: "Select your school grade",
                    searchHint: "Select your school grade",
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _selectedGradeId = value;
                      });
                    },
                    isExpanded: true,
                  )
                ]),
                const Spacer(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.black,
                    ),
                    onPressed: () => {
                          // Check that none of the values are empty
                          if (_selectedCityId != null &&
                              _selectedLanguagesIds.isNotEmpty &&
                              _selectedBoardId != null &&
                              _selectedGradeId != null)
                            {_submitRegistration(context)}
                          else
                            {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'Please fill in all fields'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ))
                            }
                        },
                    child: const Text('Complete registration',
                        style: TextStyle(fontSize: 17.0))),
                const SizedBox(height: 15)
              ],
            ),
          )
        ]),
      ),
    );
  }
}
