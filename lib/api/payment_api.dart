import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/providers/auth.dart';

class PaymentApi {
  static PaymentApi _instance;
  static String paystackPublicKey =
      "pk_test_1ba9e2ab045468113516c27812c38449e38f8309";

  PaymentApi._();

  static Future<PaymentApi> getInstance() async {
    if (_instance == null) {
      await initialize();
      _instance = PaymentApi._();
    }
    return _instance;
  }

  static Future<dynamic> initialize() {
    return PaystackPlugin.initialize(publicKey: paystackPublicKey);
  }

  Future<dynamic> getDeliveryFee(distance) async {
    try {
      String url =
          'https://us-central1-delivery-client-5f214.cloudfunctions.net/calculateDeliveryFee?distance=$distance';
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        if (data['successful'] == true) {
          return data['data'];
        }
        return null;
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  Future<CheckoutResponse> beginTransaction(
      {BuildContext context, Map<String, dynamic> transactionDetails}) async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    PaymentCard card = PaymentCard(
        number: '4084084084084081', cvc: '408', expiryMonth: 4, expiryYear: 21);
    Charge charge = Charge()
      ..accessCode = transactionDetails['access_code']
      ..card = card
      ..amount = transactionDetails['fee'] * 100
      ..reference = transactionDetails['reference']
      ..email = authProvider.firebaseUser.email;
    return PaystackPlugin.checkout(context, charge: charge);
  }

  Future<Map<String, dynamic>> initializeGamePurchaseTransaction(
      {BuildContext context, int fee, String gameId}) async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    http.Response response =
        await http.post('$endpointBaseUrl/transaction/initializeGamePurchase',
            body: JsonEncoder().convert({
              'email': authProvider.firebaseUser.email,
              'userId': authProvider.firebaseUser.uid,
              'amount': fee,
              'gameId': gameId
            }),
            headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      Map body = JsonDecoder().convert(response.body);
      if (!body['successful']) {
        throw (body['message']);
      }
      print(body['data']['data']['reference']);
      return {
        'access_code': body['data']['data']['access_code'],
        'reference': body['data']['data']['reference'],
        'fee': fee
      };
    }
    throw ('Server Error');
  }
}