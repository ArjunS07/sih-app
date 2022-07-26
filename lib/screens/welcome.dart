
import 'package:flutter/material.dart';

import 'package:sih_app/screens/signup.dart';
import 'package:sih_app/screens/student_start.dart';

import 'package:sih_app/screens/login.dart';

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
        title: const Text('Hello'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Placeholder welcome text',
            ),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JoinSchool()),
                      ),
                    },
                child: const Text('Student')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AccountSignup(isStudent: false)),
                      ),
                    },
                child: const Text('Tutor')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      ),
                    },
                child: const Text('Log in'))
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return _welcomePage(context);
  }
}
