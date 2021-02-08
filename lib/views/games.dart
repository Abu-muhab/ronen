import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/providers/auth.dart';
import 'package:ronen/widgets/game_cover.dart';

class MyGames extends StatefulWidget {
  @override
  State createState() => MyGamesState();
}

class MyGamesState extends State<MyGames> {
  String dropDownValue = 'borrowed';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  'View',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton<String>(
                  underline: Container(),
                  items: [
                    DropdownMenuItem(
                        child: Text('Borrowed Games',
                            style: TextStyle(color: Colors.white)),
                        value: 'borrowed'),
                    DropdownMenuItem(
                      child: Text('Bought games',
                          style: TextStyle(color: Colors.white)),
                      value: 'bought',
                    ),
                  ],
                  onChanged: (selected) {
                    if (dropDownValue == selected) {
                      return;
                    }
                    setState(() {
                      dropDownValue = selected;
                    });
                  },
                  value: dropDownValue,
                  dropdownColor: Colors.blueAccent,
                  elevation: 5,
                ),
                SizedBox(
                  width: 20,
                ),
                // Text(
                //   'Choose',
                //   style: TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.w500,
                //       fontSize: 15),
                // ),
                // SizedBox(
                //   width: 10,
                // ),
                // DropdownButton<String>(
                //   underline: Container(),
                //   items: [
                //     DropdownMenuItem(
                //         child: Text('All',
                //             style:
                //                 TextStyle(color: Colors.white))),
                //     DropdownMenuItem(
                //         child: Text('Availabe to lend',
                //             style:
                //                 TextStyle(color: Colors.white)))
                //   ],
                //   onChanged: (slected) {},
                //   dropdownColor: Colors.blueAccent,
                //   elevation: 5,
                // ),
              ],
            ),
          ),
        ),
        Container(
          height: 15,
          width: MediaQuery.of(context).size.width,
          color: kPrimaryColorDark,
        ),
        Expanded(
            child: dropDownValue != "bought" ? Container() : PurchasedGames())
      ],
    );
  }
}

class PurchasedGames extends StatefulWidget {
  PurchasedGames({Key key}) : super(key: key);

  @override
  PurchasedGamesState createState() => PurchasedGamesState();
}

List<GamePurchaseTransaction> savedPurchaseTransactions = [];
double savedPurchaseScrollOffset;

class PurchasedGamesState extends State<PurchasedGames> {
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<GamePurchaseTransaction> transactions;
  bool fetchingTransactions = true;

  @override
  void initState() {
    super.initState();
    if (savedPurchaseScrollOffset != null) {
      scrollController =
          new ScrollController(initialScrollOffset: savedPurchaseScrollOffset);
    }
    scrollController.addListener(() {
      savedPurchaseScrollOffset = scrollController.offset;
    });
    fetchingTransactions = true;
    if (savedPurchaseTransactions.length > 0) {
      transactions = savedPurchaseTransactions;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedPurchaseTransactions.length == 0) {
        getGames();
      }
    });
  }

  Future<void> getGames() async {
    print('getting transactions');
    setState(() {
      fetchingTransactions = true;
    });
    try {
      http.Response response = await http.get(endpointBaseUrl +
          "/user/purchasedGames?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        List rawTransactions = data['data']['transactions'];
        List<GamePurchaseTransaction> transactions;
        transactions = rawTransactions.map((e) {
          return GamePurchaseTransaction.fromJson(e);
        }).toList();
        this.transactions = transactions;
        savedPurchaseTransactions = transactions;
      }
      setState(() {
        fetchingTransactions = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingTransactions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: kPrimaryColorLight,
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(0),
            child: transactions == null && fetchingTransactions == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : transactions == null && fetchingTransactions == false
                    ? Center(
                        child: RaisedButton(
                          color: Colors.blueAccent,
                          onPressed: () {
                            getGames();
                          },
                          child: Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    : transactions.length == 0
                        ? Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                "Nothing to see here yet",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            child: ListView.builder(
                              controller: scrollController,
                              itemBuilder: (context, count) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GameCover(
                                      game: transactions[count].game,
                                      transaction: transactions[count],
                                    ),
                                    Container(
                                      height: 15,
                                      width: MediaQuery.of(context).size.width,
                                      color: kPrimaryColorDark,
                                    ),
                                  ],
                                );
                              },
                              itemCount: transactions.length,
                              physics: BouncingScrollPhysics(),
                            ),
                            onRefresh: () async {
                              await getGames();
                            }),
          ))
        ],
      ),
    );
  }
}
