import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/widgets/decorated_icon.dart';
import 'package:ronen/widgets/game_cover.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool menuOpen = false;
  List<Game> games;
  bool fetchingGme = true;
  bool isLazyLoading = false;
  String orderBy = "name";

  @override
  void initState() {
    super.initState();
    fetchingGme = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getGames();
    });
    scrollController.addListener(() async {
      if ((scrollController.position.pixels + 1) >=
          scrollController.position.maxScrollExtent) {
        if (isLazyLoading == false) {
          setState(() {
            isLazyLoading = true;
          });
          await getGames(
              append: true,
              lastGameId: games != null
                  ? games.length > 0
                      ? games[games.length - 1].gameId
                      : null
                  : null);
          setState(() {
            isLazyLoading = false;
          });
        }
      }
    });
  }

  Future<void> getGames({bool append = false, String lastGameId}) async {
    if (append == false) {
      setState(() {
        fetchingGme = true;
      });
    }
    try {
      http.Response response = await http.get(endpointBaseUrl +
          "/game/listGames?limit=9&order_by=$orderBy${lastGameId == null ? "" : "&last_visible_id=$lastGameId"}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        if (data['data']['length'] == 0 && this.games != null) {
          if (this.games.length > 0) {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('You have seen it all!')],
              ),
              duration: Duration(milliseconds: 500),
            ));
          }
        }
        List rawGames = data['data']['games'];
        List<Game> games;
        games = rawGames.map((e) {
          return Game.fromJson(e);
        }).toList();
        if (games == null) {
          games = [];
        }
        if (append == true) {
          this.games.addAll(games);
        } else {
          this.games = games;
        }
      }
      if (append == false) {
        setState(() {
          fetchingGme = false;
        });
      }
    } catch (e) {
      print(e);
      if (append == false) {
        setState(() {
          fetchingGme = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(0, 0, 20, 1),
      child: Stack(
        children: [
          AnimatedPositioned(
            curve: Curves.linear,
            duration: Duration(milliseconds: 200),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(0, 0, 20, 1),
                  title: Text('Ronen'),
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        menuOpen = !menuOpen;
                      });
                    },
                    child: Icon(Icons.menu),
                  ),
                  actions: [
                    GestureDetector(
                      child: Icon(Icons.search),
                      onTap: () {
                        Navigator.pushNamed(context, 'search');
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: kPrimaryColorLight,
                  child: Column(
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
                                'Sort by',
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
                                      child: Text('Demand',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      value: 'name'),
                                  DropdownMenuItem(
                                    child: Text('Release Date',
                                        style: TextStyle(color: Colors.white)),
                                    value: 'release_date',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Date Added',
                                        style: TextStyle(color: Colors.white)),
                                    value: 'date_created',
                                  )
                                ],
                                onChanged: (selected) {
                                  if (orderBy == selected) {
                                    return;
                                  }
                                  setState(() {
                                    orderBy = selected;
                                    games = null;
                                    getGames();
                                  });
                                },
                                value: orderBy,
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
                          child: Padding(
                        padding: EdgeInsets.all(0),
                        child: games == null && fetchingGme == true
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : games == null && fetchingGme == false
                                ? Center(
                                    child: RaisedButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        getGames();
                                      },
                                      child: Text('Retry',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  )
                                : RefreshIndicator(
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemBuilder: (context, count) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 180,
                                              child: GameCover(
                                                game: games[count],
                                              ),
                                            ),
                                            Container(
                                              height: 15,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: kPrimaryColorDark,
                                            ),
                                            count == games.length - 1 &&
                                                    isLazyLoading == true
                                                ? Container(
                                                    height: 100,
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.blue[
                                                                      900]),
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        );
                                      },
                                      itemCount: games.length,
                                      physics: BouncingScrollPhysics(),
                                    ),
                                    onRefresh: () async {
                                      await getGames();
                                    }),
                      ))
                    ],
                  ),
                ),
              ),
            ),
            left: menuOpen == true ? 80 : 0,
          ),
          AnimatedPositioned(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: 81,
              color: kPrimaryColorDark,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight,
                    ),
                    DecoratedIcon(
                      iconData: Icons.home,
                      width: 50,
                      backgroundColor: Colors.blueAccent,
                      iconColor: Colors.white,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.shield,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.chat,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.supervisor_account_sharp,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            left: menuOpen == false ? -80 : 0,
          )
        ],
      ),
    );
  }
}
