import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ronen/models/game.dart';

class GamePurchaseTransaction {
  int amount;
  Timestamp transactionDate;
  String deliveryStatus;
  String packageId;
  String transactionReference;
  Game game;

  GamePurchaseTransaction(
      {this.game,
      this.amount,
      this.packageId,
      this.deliveryStatus,
      this.transactionDate,
      this.transactionReference});

  factory GamePurchaseTransaction.fromJson(Map json) {
    return GamePurchaseTransaction(
        game: Game.fromJson(json['game']),
        transactionDate: Timestamp(json['paymentVerificationTime']['_seconds'],
            json['paymentVerificationTime']['_nanoseconds']),
        deliveryStatus: json['deliveryStatus'],
        amount: json['amount'],
        packageId: json['packageId'],
        transactionReference: json['transactionReference']);
  }
}
