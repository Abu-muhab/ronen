import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ronen/views/home.dart';
import 'package:ronen/views/search.dart';

void main() {
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
        'search': (context) => Search()
      },
      home: MyHomePage(),
    );
  }
}
