import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ronen/providers/auth.dart';
import 'package:ronen/views/bookmarks.dart';
import 'package:ronen/views/home.dart';
import 'package:ronen/views/search.dart';
import 'package:ronen/views/signin.dart';
import 'package:ronen/views/signup.dart';
import 'package:ronen/views/games.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MyApp(),
  ));
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
        'home': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.firebaseUser == null) {
                  return Signin();
                }
                return MyHomePage();
              },
            ),
        'search': (context) => Search(),
        'signin': (context) => Signin(),
        'signup': (context) => Signup(),
        'bookmarks': (context) => Bookmarks(),
        'games': (context) => MyGames()
      },
      initialRoute: 'home',
    );
  }
}
