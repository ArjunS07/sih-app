import 'package:flutter/material.dart';

class JoinSchool extends StatefulWidget {
  JoinSchool({Key? key}) : super(key: key);

  @override
  State<JoinSchool> createState() => _JoinSchoolState();
}

class _JoinSchoolState extends State<JoinSchool> {
  final formController = TextEditingController();

  void _joinSchoolWithCode() {
    print('Joining school with code: ${formController.text}');
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
                  onSubmitted: (_) => _joinSchoolWithCode(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your school join code',
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class StudentSignUp extends StatefulWidget {
  StudentSignUp({Key? key}) : super(key: key);

  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
