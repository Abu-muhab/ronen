import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/providers/auth.dart';
import 'package:ronen/widgets/game_cover.dart';

class MyGames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromRGBO(0, 0, 20, 1),
            title: Text('My Games'),
            actions: [
              SizedBox(
                width: 10,
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Purchased',
                ),
                Tab(
                  text: 'Borrowed',
                ),
              ],
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kPrimaryColorLight,
            child: TabBarView(
              children: [
                PurchasedGames(),
                Container(),
              ],
            ),
          )),
    );
  }
}

class PurchasedGames extends StatefulWidget {
  PurchasedGames({Key key}) : super(key: key);

  @override
  PurchasedGamesState createState() => PurchasedGamesState();
}

class PurchasedGamesState extends State<PurchasedGames> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<GamePurchaseTransaction> transactions;
  bool fetchingTransactions = true;

  @override
  void initState() {
    super.initState();
    fetchingTransactions = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getGames();
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
          Container(
            height: 10,
            width: MediaQuery.of(context).size.width,
            color: kPrimaryColorDark,
          ),
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
