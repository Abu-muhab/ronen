import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ronen/globals.dart';

class UserApi {
  static Future<bool> addToBookmarks({String userId, String gameId}) async {
    try {
      http.Response response = await http.post(
          Uri.parse(endpointBaseUrl + "/user/bookmarks"),
          headers: {"Content-Type": "application/json"},
          body: JsonEncoder().convert({"userId": userId, "gameId": gameId}));

      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        if (data['successful'] == true) {
          return true;
        } else {
          throw (data['message']);
        }
      } else {
        throw ('Error adding to bookmarks');
      }
    } on SocketException catch (_) {
      throw ('No internet connection');
    }
  }
}
