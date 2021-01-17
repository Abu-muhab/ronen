import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ronen/views/home.dart';
import 'package:ronen/views/search.dart';
import 'package:ronen/views/signin.dart';
import 'package:ronen/views/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {
        'home': (context) => MyHomePage(),
        'search': (context) => Search(),
        'signin': (context) => Signin(),
        'signup': (context) => Signup(),
      },
      initialRoute: 'signin',
    );
  }
}
