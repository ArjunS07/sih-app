import 'package:flutter/material.dart';

import 'package:sih_app/screens/registration/signup.dart';
import 'package:sih_app/screens/registration/student_start.dart';

import 'package:sih_app/screens/registration/login.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _welcomePage(context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Welcome to APPNAME'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(
                image: AssetImage('assets/images/volunteer_with_students.png'),
                width: 100,
                height: 103.98,
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'APPNAME connects students to volunteers across the country who want to help them learn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17.5,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  primary: Colors.black,
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JoinSchool()),
                  ),
                },
                child: const Text("I'm a student",
                    style: TextStyle(fontSize: 16.0)),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  primary: Colors.black,
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountSignup(isStudent: false)),
                  ),
                },
                child: const Text("I'm a volunteer",
                    style: TextStyle(fontSize: 16.0)),
              ),
              const SizedBox(height: 30),
              const Divider(
                thickness: 3.0,
              ),
              const SizedBox(height: 30),
              Text('Already have an account?',
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 16)),
              const SizedBox(height: 20.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    primary: Colors.black,
                  ),
                  onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        ),
                      },
                  child: const Text("Log in", style: TextStyle(fontSize: 16.0)))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _welcomePage(context);
  }
}
