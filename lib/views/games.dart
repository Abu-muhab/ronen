import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/borrow_transaction.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/providers/auth.dart';
import 'package:ronen/widgets/game_cover.dart';

class MyGames extends StatefulWidget {
  @override
  State createState() => MyGamesState();
}

String savedDropdownState;

class MyGamesState extends State<MyGames> {
  String dropDownValue = 'borrowed';

  @override
  void initState() {
    if (savedDropdownState != null) {
      dropDownValue = savedDropdownState;
    }
    super.initState();
  }

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
                      child: Text('Purchased',
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
                      savedDropdownState = selected;
                    });
                  },
                  value: dropDownValue,
                  dropdownColor: Colors.blueAccent,
                  elevation: 5,
                ),
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
            child: dropDownValue != "bought"
                ? Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: CurrentBorrowedGame(),
                      ),
                      Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width,
                        color: kPrimaryColorDark,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Borrowing History",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      ),
                      Expanded(child: BorrowingHistory())
                    ],
                  )
                : PurchasedGames())
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
                                      purchaseTransaction: transactions[count],
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

class BorrowingHistory extends StatefulWidget {
  BorrowingHistory({Key key}) : super(key: key);

  @override
  State createState() => BorrowingHistoryState();
}

List<BorrowTransaction> savedBorrowTransaction = [];
double savedBorrowScrollOffset;

class BorrowingHistoryState extends State<BorrowingHistory> {
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<BorrowTransaction> transactions;
  bool fetchingTransactions = true;

  @override
  void initState() {
    super.initState();
    if (savedPurchaseScrollOffset != null) {
      scrollController =
          new ScrollController(initialScrollOffset: savedBorrowScrollOffset);
    }
    scrollController.addListener(() {
      savedBorrowScrollOffset = scrollController.offset;
    });
    fetchingTransactions = true;
    if (savedPurchaseTransactions.length > 0) {
      transactions = savedBorrowTransaction;
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
          "/user/borrowingHistory?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        List rawTransactions = data['data']['transactions'];
        List<BorrowTransaction> transactions;
        transactions = rawTransactions.map((e) {
          return BorrowTransaction.fromJson(e);
        }).toList();
        this.transactions = transactions;
        savedBorrowTransaction = transactions;
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
                                      borrowTransaction: transactions[count],
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

class CurrentBorrowedGame extends StatefulWidget {
  CurrentBorrowedGame({Key key}) : super(key: key);

  @override
  State createState() => CurrentBorrowedGameState();
}

BorrowTransaction savedCurrentBorrowedGame;

class CurrentBorrowedGameState extends State<CurrentBorrowedGame> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  BorrowTransaction currentBorrowedGame;
  bool fetchingTransactions = true;

  @override
  void initState() {
    super.initState();
    fetchingTransactions = true;
    if (savedCurrentBorrowedGame != null) {
      currentBorrowedGame = savedCurrentBorrowedGame;
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
          "/user/borrowedGames?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        List rawTransactions = data['data']['transactions'];
        if (rawTransactions.length != 0) {
          BorrowTransaction transaction;
          transaction = BorrowTransaction.fromJson(rawTransactions[0]);
          this.currentBorrowedGame = transaction;
          savedCurrentBorrowedGame = transaction;
        } else {
          this.currentBorrowedGame = BorrowTransaction();
        }
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
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(),
          borderRadius: BorderRadius.circular(15)),
      child: currentBorrowedGame == null && fetchingTransactions == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : currentBorrowedGame == null && fetchingTransactions == false
              ? Center(
                  child: RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: () {
                      getGames();
                    },
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                )
              : currentBorrowedGame.game == null
                  ? Center(
                      child: Text("You do not have a game in your possession"),
                    )
                  : SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            child: Opacity(
                              opacity: 0.6,
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: currentBorrowedGame.game.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
