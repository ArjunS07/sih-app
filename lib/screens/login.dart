import 'package:flutter/material.dart';
import 'package:sih_app/utils/auth_api_utils.dart';
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Widget _decideIcon() {
    if (_obscurePassword) {
      return const Icon(Icons.visibility);
    } else {
      return const Icon(Icons.visibility_off);
    }
  }

  void _login(context) async {
    if (_formKey.currentState!.validate()) {
      print('valid form state');
      login(_emailController.text, _passController.text).then((account) {
        if (account != null) {
          print('Found account');
          persistence_utils.upDateSharedPreferences(
              account.authToken!, account.accountId);
          persistence_utils.getPrefs().then((prefs) => {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BottomTabController(prefs: prefs))),
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Success'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ))
              });
          // TODO: Remove dialog and redirect to home screen instead

        } else {
          print('No account found');
          setState(() {
            _errorText = 'Invalid user credentials';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
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
                      'Log in',
                      style: TextStyle(fontSize: 24),
                    ),
                    Spacer(),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      controller: _emailController,
                      decoration: InputDecoration(
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
                    SizedBox(height: 25.0),
                    TextFormField(
                        obscureText: _obscurePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        controller: _passController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Enter your password',
                          suffixIcon: _obscurePassword ? Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(onTap: _togglePasswordVisibility, child: const Icon(Icons.visibility)),
                          ) : Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(onTap: _togglePasswordVisibility, child: const Icon(Icons.visibility_off)),
                          )
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        }),
                    Text(
                      _errorText,
                      style: TextStyle(color: Colors.red),
                    ),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            print('Submitting...');
                            _login(context);
                          }
                        },
                        child: Text('Log in')),
                    Spacer(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
