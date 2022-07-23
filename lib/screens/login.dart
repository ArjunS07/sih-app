import 'package:flutter/material.dart';
import 'package:sih_app/utils/auth_api_utils.dart';

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

  void _login(context) {
    if (_formKey.currentState!.validate()) {
      print('valid form state');
      login(_emailController.text, _passController.text).then((account) {
        if (account != null) {
          print('Found account');
          // TODO: Remove
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
                  ));
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
