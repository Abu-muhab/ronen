import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/providers/auth.dart';

class BorrowApi {
  static Future<bool> borrowCd(Game game, BuildContext context) async {
    String userId =
        Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid;
    try {
      http.Response response = await http.post(
          Uri.parse('$endpointBaseUrl/transaction/borrowGame'),
          body:
              JsonEncoder().convert({'userId': userId, 'gameId': game.gameId}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map body = JsonDecoder().convert(response.body);
        if (!body['successful']) {
          throw (body['message']);
        }
        return true;
      } else {
        throw ('Something went wrong. Try again');
      }
    } on SocketException catch (_) {
      throw ('No internet connection. Try again');
    }
  }

  static Future<bool> returnCd(Game game, BuildContext context) async {
    String userId =
        Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid;
    try {
      http.Response response = await http.post(
          Uri.parse('$endpointBaseUrl/transaction/returnGame'),
          body:
              JsonEncoder().convert({'userId': userId, 'gameId': game.gameId}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map body = JsonDecoder().convert(response.body);
        if (!body['successful']) {
          throw (body['message']);
        }
        return true;
      } else {
        throw ('Something went wrong. Try again');
      }
    } on SocketException catch (_) {
      throw ('No internet connection. Try again');
    }
  }
}
