import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:sih_app/screens/welcome.dart';
import 'package:sih_app/screens/bottom_tab_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://7e25af76e0bb42f99b1d91e875d1b675@o879237.ingest.sentry.io/6638117';
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(MyApp(prefs: prefs)),
    );
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  _decideMainPage() {
    if (prefs.get('token') != null && prefs.get('id') != null) {
      return BottomTabController(
        prefs: prefs,
      );
    } else {
      return WelcomePage();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.white,
          ),
        ),
        home: _decideMainPage());
  }
}
