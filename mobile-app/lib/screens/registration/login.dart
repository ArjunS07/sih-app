// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:sih_app/utils/accounts_api_utils.dart';
import 'package:sih_app/utils/persistence_utils.dart' as persistence_utils;

import 'package:sih_app/screens/bottom_tab_controller.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String _errorText = '';
  bool _obscurePassword = true;

  bool _isInApiCall = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login(context) async {
    if (_formKey.currentState!.validate()) {
      print('valid form state');
      setState(() {
        _isInApiCall = true;
      });
      login(_emailController.text, _passController.text).then((account) {
        if (account != null) {
          print('Found account');
          setState(() {
            _isInApiCall = false;
          });
          persistence_utils.upDateSharedPreferences(
              account.authToken!, account.accountId);
          persistence_utils.getPrefs().then((prefs) => {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BottomTabController(prefs: prefs))),
              });
        } else {
          print('No account found');
          setState(() {
            _errorText = 'Invalid user credentials';
            _isInApiCall = false;
          });
        }
      }).onError((error, stackTrace) {
        setState(() {
          _errorText = 'Invalid user credentials';
          _isInApiCall = false;
        });
      });
    }
  }

  Widget _bodyWidget() {
    return Center(
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    'Log in',
                    style: TextStyle(fontSize: 24),
                  ),
                  const Spacer(),
                  TextFormField(
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
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
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      controller: _passController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Enter your password',
                          suffixIcon: _obscurePassword
                              ? Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: GestureDetector(
                                      onTap: _togglePasswordVisibility,
                                      child: const Icon(Icons.visibility)),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: GestureDetector(
                                      onTap: _togglePasswordVisibility,
                                      child: const Icon(Icons.visibility_off)),
                                )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      }),
                  Text(
                    _errorText,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Spacer(),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        primary: Colors.black,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          print('Submitting...');
                          _login(context);
                        }
                      },
                      child: const Text('Log in')),
                  const Spacer(),
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Log in'),
        ),
        body:
            ModalProgressHUD(inAsyncCall: _isInApiCall, child: _bodyWidget()));
  }
}
