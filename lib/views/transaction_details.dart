import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:ronen/util.dart';

class TransactionDetails extends StatelessWidget {
  final GamePurchaseTransaction transaction;
  TransactionDetails({this.transaction});
  @override
  Widget build(BuildContext context) {
    double labelSize = 15;
    double detailsSize = 20;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 20, 1),
        title: Text('Transaction'),
        actions: [
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: kPrimaryColorLight,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller: TextEditingController(
                        text: transaction.amount.toString()),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Amount Paid',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller: TextEditingController(
                        text: convertTimeStampToString(
                            transaction.transactionDate)),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Transaction Date',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller: TextEditingController(
                        text: transaction.transactionReference),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Transaction Reference',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller:
                        TextEditingController(text: transaction.packageId),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Package Id',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller:
                        TextEditingController(text: transaction.game.name),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Purchased CD',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    readOnly: true,
                    style:
                        TextStyle(color: Colors.white, fontSize: detailsSize),
                    controller: TextEditingController(text: 'Processing'),
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent)),
                        labelText: 'Delivery Status',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: labelSize)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
