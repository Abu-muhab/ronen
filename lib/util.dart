import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String convertTimeStampToString(Timestamp timestamp) {
  return "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}";
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}

void showBasicMessageDialog(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OKAY",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });
}

Future<bool> showBasicConfirmationDialog(
    String message, BuildContext context) async {
  bool value = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "YES",
                  style: TextStyle(color: Colors.blueAccent),
                )),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  "NO",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });
  return value;
}

void showPersistentLoadingIndicator(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ),
        );
      },
      barrierDismissible: false);
}
