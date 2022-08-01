import 'package:flutter/material.dart';

import 'package:sih_app/models/School.dart';

import 'package:sih_app/screens/registration/student_start.dart';
import 'package:sih_app/screens/registration/tutor_start.dart';

class AccountSignup extends StatefulWidget {
  final bool isStudent;
  School? school;
  AccountSignup({Key? key, required this.isStudent, this.school})
      : super(key: key);

  @override
  State<AccountSignup> createState() => _AccountSignupState();
}

class _AccountSignupState extends State<AccountSignup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  _submitRegistration(context) async {
    if (widget.isStudent) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetails(
                school: widget.school!,
                email: _emailController.text,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                password: _passController.text),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorDetails(
                email: _emailController.text,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                password: _passController.text),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isStudent
            ? const Text('Student Sign Up')
            : const Text('Tutor sign up'),
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
                    const Spacer(),
                    Text(
                      widget.isStudent
                          ? 'Sign up as a student'
                          : 'Sign up as a tutor',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Spacer(),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'First name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 25.0),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      controller: _emailController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 25.0),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      controller: _passController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 25.0),
                    TextFormField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        controller: _passConfirmController,
                        decoration: const InputDecoration(
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
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            print('Submitting...');
                            _submitRegistration(context);
                          }
                        },
                        child: const Text('Sign up')),
                    const Spacer(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
