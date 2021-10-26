import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/api/borrow_api.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/borrow_transaction.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/providers/auth.dart';
import 'package:ronen/util.dart';
import 'package:ronen/widgets/borrow_history_tile.dart';
import 'package:ronen/widgets/game_cover.dart';

class MyGames extends StatefulWidget {
  @override
  State createState() => MyGamesState();
}

String savedDropdownState;
GlobalKey<CurrentBorrowedGameState> currentBorrowedKey = GlobalKey();
GlobalKey<BorrowingHistoryState> borrowHistoryKey = GlobalKey();

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
                ? RefreshIndicator(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: CurrentBorrowedGame(
                            key: currentBorrowedKey,
                          ),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ),
                        Expanded(
                            child: BorrowingHistory(
                          key: borrowHistoryKey,
                        ))
                      ],
                    ),
                    onRefresh: () async {
                      List<Future> futures = [];
                      futures.add(currentBorrowedKey.currentState.getGames());
                      futures.add(borrowHistoryKey.currentState.getGames());
                      await Future.wait(futures);
                    })
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
      getGames();
    });
  }

  Future<void> getGames() async {
    print('getting transactions');
    setState(() {
      fetchingTransactions = true;
    });
    try {
      http.Response response = await http.get(Uri.parse(endpointBaseUrl +
          "/user/purchasedGames?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}"));
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
                                      height: count == transactions.length - 1
                                          ? 500
                                          : 15,
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
    if (savedBorrowScrollOffset != null) {
      scrollController =
          new ScrollController(initialScrollOffset: savedBorrowScrollOffset);
    }
    scrollController.addListener(() {
      savedBorrowScrollOffset = scrollController.offset;
    });
    fetchingTransactions = true;
    if (savedBorrowTransaction.length > 0) {
      transactions = savedBorrowTransaction;
    }
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
      http.Response response = await http.get(Uri.parse(endpointBaseUrl +
          "/user/borrowingHistory?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}"));
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
      color: kPrimaryColorLight,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: transactions == null && fetchingTransactions == true
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                ),
              )
            : transactions == null && fetchingTransactions == false
                ? Center(
                    child: RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        try {
                          currentBorrowedKey.currentState.getGames();
                        } catch (_) {}
                        getGames();
                      },
                      child:
                          Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  )
                : transactions.length == 0
                    ? Center(
                        child: Container(
                          height: 500,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text(
                              "Nothing to see here yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Column(
                            children: transactions.map((e) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BorrowHistoryTile(
                                    transaction: e,
                                  ),
                                  Container(
                                    height: 15,
                                    width: MediaQuery.of(context).size.width,
                                    color: kPrimaryColorDark,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 400,
                          )
                        ],
                      ),
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
      getGames();
    });
  }

  Future<void> getGames() async {
    print('getting transactions');
    setState(() {
      fetchingTransactions = true;
    });
    try {
      http.Response response = await http.get(Uri.parse(endpointBaseUrl +
          "/user/borrowedGames?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}"));
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
          savedCurrentBorrowedGame = this.currentBorrowedGame;
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
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.blue]),
          border: Border.all(),
          borderRadius: BorderRadius.circular(15)),
      child: currentBorrowedGame == null && fetchingTransactions == true
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(kPrimaryColorDark)),
            )
          : currentBorrowedGame == null && fetchingTransactions == false
              ? Center(
                  child: RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: () {
                      try {
                        borrowHistoryKey.currentState.getGames();
                      } catch (_) {}
                      getGames();
                    },
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                )
              : currentBorrowedGame.game == null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "You do not have a game in your possession",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
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
                          Center(
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Game in hand",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    currentBorrowedGame.game.name,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(),
                                      CardIcon(
                                        text: "Swap",
                                        iconData: Icons.swap_horiz,
                                      ),
                                      CardIcon(
                                        text: "Return",
                                        onTap: () async {
                                          bool value =
                                              await showBasicConfirmationDialog(
                                                  "Do you want to return this game?",
                                                  context);
                                          if (value == true) {
                                            showPersistentLoadingIndicator(
                                                context);
                                            BorrowApi.returnCd(
                                                    currentBorrowedGame.game,
                                                    context)
                                                .then((value) {
                                              Navigator.pop(context);
                                              if (value == true) {
                                                showBasicMessageDialog(
                                                    'Your request is being processed',
                                                    context);
                                                try {
                                                  currentBorrowedKey
                                                      .currentState
                                                      .getGames();
                                                  borrowHistoryKey.currentState
                                                      .getGames();
                                                } catch (_) {}
                                              } else {
                                                showBasicMessageDialog(
                                                    'Something went wrong. Try again',
                                                    context);
                                              }
                                            }).catchError((err) {
                                              Navigator.pop(context);
                                              showBasicMessageDialog(
                                                  err.toString(), context);
                                            });
                                          }
                                        },
                                        iconData: Icons.keyboard_return,
                                      ),
                                      CardIcon(
                                        text: "Extend",
                                        iconData: Icons.timer,
                                      ),
                                      Container()
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: kPrimaryColorDark,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "Due Date: ${convertTimeStampToString(currentBorrowedGame.returnDate)}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
    );
  }
}

class CardIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Function onTap;
  CardIcon({this.text, this.iconData, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: kPrimaryColorLight,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  iconData,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
