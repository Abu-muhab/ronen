import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ronen/models/borrow_transaction.dart';
import 'package:ronen/util.dart';

class BorrowHistoryTile extends StatelessWidget {
  final BorrowTransaction transaction;
  BorrowHistoryTile({this.transaction});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        children: [
          Container(
            height: 100,
            width: 100,
            child: CachedNetworkImage(
              imageUrl: transaction.game.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
              child: ListTile(
            title: Text(
              transaction.game.name,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Date received: ${convertTimeStampToString(transaction.dateReceived)}\n"
              "Date Due: ${convertTimeStampToString(transaction.returnDate)}",
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(
              Icons.expand,
              color: Colors.white,
            ),
          ))
        ],
      ),
    );
  }
}
