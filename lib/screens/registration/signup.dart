import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _formController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  bool _obscureMainPassword = true;
  bool _obscureConfirmPassword = true;

  void _toggleMainPasswordVisibility() {
    setState(() {
      _obscureMainPassword = !_obscureMainPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

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

  Widget _bodyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
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
                  keyboardType: TextInputType.emailAddress,
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
                  obscureText: _obscureMainPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  controller: _passController,
                  decoration: InputDecoration(
                    suffixIcon: _obscureMainPassword
                        ? Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(
                                onTap: _toggleMainPasswordVisibility,
                                child: const Icon(Icons.visibility)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(
                                onTap: _toggleMainPasswordVisibility,
                                child: const Icon(Icons.visibility_off)),
                          ),
                    border: const OutlineInputBorder(),
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
                    obscureText: _obscureConfirmPassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    controller: _passConfirmController,
                    decoration: InputDecoration(
                      suffixIcon: _obscureConfirmPassword
                          ? Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: GestureDetector(
                                  onTap: _toggleConfirmPasswordVisibility,
                                  child: const Icon(Icons.visibility)),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: GestureDetector(
                                  onTap: _toggleConfirmPasswordVisibility,
                                  child: const Icon(Icons.visibility_off)),
                            ),
                      border: const OutlineInputBorder(),
                      labelText: 'Confirm your password',
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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.black,
                    ),
                    onPressed: () => {
                          if (_formKey.currentState!.validate())
                            {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              _submitRegistration(context)
                            }
                        },
                    child: const Text('Sign up')),
                const Spacer(),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create your account'),
        ),
        body: _bodyWidget());
  }
}
