import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/globals.dart';

class AuthProvider extends ChangeNotifier {
  User firebaseUser;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      firebaseUser = user;
      if (firebaseUser != null) {
        //TODO fetch user data
      }
      notifyListeners();
    });
  }

  Future<bool> signin({String email, String password}) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      return true;
    }).catchError((err) {
      print(err);
      if (err.toString().contains('unknown')) {
        throw ("No internet connection");
      }
      throw ("Email or Password is incorrect");
    });
  }

  void signout() {
    FirebaseAuth.instance.signOut();
  }

  Future<bool> signup({String email, String password}) async {
    try {
      http.Response response = await http.post(
          Uri.parse(endpointBaseUrl + "/auth/signup"),
          headers: {"Content-Type": "application/json"},
          body: JsonEncoder().convert({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        if (data['successful'] == true) {
          return true;
        } else {
          if (data['error']['message'] != null) {
            throw (data['error']['message']);
          } else {
            throw ('Inavlid Email. Try again');
          }
        }
      } else {
        print(response.body);
        throw ('Check your details and try again');
      }
    } on SocketException catch (_) {
      throw ('No internet connection');
    }
  }
}
