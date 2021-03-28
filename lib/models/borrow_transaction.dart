import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ronen/models/game.dart';

class BorrowTransaction {
  Timestamp dateReceived;
  Timestamp returnDate;
  String deliveryStatus;
  String packageId;
  String transactionReference;
  Game game;

  BorrowTransaction(
      {this.game,
      this.packageId,
      this.deliveryStatus,
      this.dateReceived,
      this.returnDate,
      this.transactionReference});

  factory BorrowTransaction.fromJson(Map json) {
    return BorrowTransaction(
        game: Game.fromJson(json['game']),
        dateReceived: Timestamp(json['dateReceived']['_seconds'],
            json['dateReceived']['_nanoseconds']),
        returnDate: Timestamp(json['expectedReturnDate']['_seconds'],
            json['expectedReturnDate']['_nanoseconds']),
        deliveryStatus: json['deliveryStatus'],
        packageId: json['packageId'],
        transactionReference: json['transactionReference']);
  }
}
