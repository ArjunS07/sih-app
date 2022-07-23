import 'package:flutter/material.dart';
import 'package:sih_app/screens/signup.dart';
import 'package:sih_app/screens/student_start.dart';
import 'package:sih_app/screens/tutor_start.dart';
import 'package:sih_app/screens/login.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Hello'),
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
                child: Text('Student')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountSignup(isStudent: false)),
                      ),
                    },
                child: Text('Tutor')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      ),
                    },
                child: Text('Log in'))
          ],
        ),
      ),
    );
  }
}
