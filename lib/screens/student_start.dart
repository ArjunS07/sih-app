import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';

import 'package:sih_app/models/School.dart';
import 'package:sih_app/models/Account.dart';
import 'package:sih_app/models/Student.dart';
import 'package:sih_app/utils/api_utils.dart';
import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/models/choice.dart';

class JoinSchool extends StatefulWidget {
  JoinSchool({Key? key}) : super(key: key);

  @override
  State<JoinSchool> createState() => _JoinSchoolState();
}

class _JoinSchoolState extends State<JoinSchool> {
  final formController = TextEditingController();

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

  _submitSchoolJoinCode(String joinCode, BuildContext context) {
    _getSchoolFromJoinCode(joinCode).then((school) {
      if (school != null) {
        print('Joining school ${school.name}');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmSchool(school: school),
            ));
      }
    });
  }

  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join as a student'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: formController,
                  onSubmitted: (code) => _submitSchoolJoinCode(code, context),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your school join code',
                  ),
                ),
                ElevatedButton(
                  child: Text('Join'),
                  onPressed: () =>
                      _submitSchoolJoinCode(formController.text, context),
                ),
              ]),
        ),
      ),
    );
  }
}

class ConfirmSchool extends StatelessWidget {
  final School school;
  const ConfirmSchool({Key? key, required this.school}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join as a student'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Is this your school?',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  '${school.name}',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentSignUp(school: school),
                              ))
                        },
                    child: Text('Yes')),
              ]),
        ),
      ),
    );
  }
}

class StudentSignUp extends StatefulWidget {
  final School school;
  StudentSignUp({Key? key, required this.school}) : super(key: key);

  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  _submitRegistration(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDetails(
              school: widget.school,
              email: _emailController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              password: _passController.text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Sign Up'),
      ),
      body: Center(
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    const Text(
                      'Sign up as a student',
                      style: TextStyle(fontSize: 24),
                    ),
                    Spacer(),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Last name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      controller: _passController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return value.length < 8
                            ? 'Password length must be greater than 8 characters'
                            : null;
                      },
                    ),
                    SizedBox(height: 25.0),
                    TextFormField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        controller: _passConfirmController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Verify your password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please verify your password';
                          }
                          if (value != _passController.text) {
                            return 'Passwords do not match';
                          }
                        }),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            print('Submitting...');
                            _submitRegistration(context);
                          }
                        },
                        child: Text('Sign up')),
                    Spacer(),
                  ]),
            ),
          ),
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
    var account = await createAccount(
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

      var student = await createStudent(
              account, _selectedCityId!, _selectedLanguagesIds, widget.school, _selectedBoardId!, _selectedGradeId!)
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Column(children: [
              const Text('What languages do you speak?'),
              MultiSelectDialogField(
                items:
                    _languageChoices.map((language) => MultiSelectItem(language.id, language.name)).toList(),
                listType: MultiSelectListType.CHIP,
                onConfirm: (values) {
                  for (var value in values) {
                    _selectedLanguagesIds.add(value.toString());
                  }
                }
              ),
            ])),
            Expanded(
                child: Column(children: [
              const Text('What city do you live in?'),
              SearchChoices.single(
                items: _cityChoices
                    .map((city) => DropdownMenuItem(value: city.id, child: Text(city.name)))
                    .toList(),
                value: _selectedCityId,
                hint: "Select one",
                searchHint: "Select one",
                onChanged: (value) {
                  setState(() {
                    _selectedCityId = value;
                  });
                },
                isExpanded: true,
              )
            ])),
            Expanded(
                child: Column(children: [
              const Text('What board do you study in?'),
              SearchChoices.single(
                items: _boardChoices
                    .map((board) => DropdownMenuItem(value: board.id, child: Text(board.name)))
                    .toList(),
                value: _selectedBoardId,
                hint: "Select one",
                searchHint: "Select one",
                onChanged: (value) {
                  print(value);
                  setState(() {
                    _selectedBoardId = value;
                  });
                },
                isExpanded: true,
              )
            ])),
            Expanded(
                child: Column(children: [
              const Text('What grade do you study in?'),
              SearchChoices.single(
                items: _gradeChoices
                    .map((grade) => DropdownMenuItem(value: grade.id, child: Text(grade.name)))
                    .toList(),
                value: _selectedGradeId,
                hint: "Select one",
                searchHint: "Select one",
                onChanged: (value) {
                  print(value);
                  setState(() {
                    _selectedGradeId = value;
                  });
                },
                isExpanded: true,
              )
            ])),
            
            ElevatedButton(
                onPressed: () => {_submitRegistration(context)},
                child: Text('Complete registration')),
          ],
        )),
      ),
    );
  }
}
