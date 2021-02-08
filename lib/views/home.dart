import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:http/http.dart' as http;
import 'package:ronen/widgets/game_cover.dart';

class Home extends StatefulWidget {
  @override
  State createState() => HomeState();
}

List<Game> savedGames = [];
double savedScrollOffset;

class HomeState extends State<Home> {
  ScrollController scrollController = new ScrollController();
  List<Game> games;
  bool fetchingGme = true;
  bool isLazyLoading = false;
  String orderBy = "name";

  @override
  void initState() {
    super.initState();
    if (savedScrollOffset != null) {
      scrollController =
          new ScrollController(initialScrollOffset: savedScrollOffset);
    }
    scrollController.addListener(() {
      savedScrollOffset = scrollController.offset;
    });
    fetchingGme = true;
    if (savedGames.length > 0) {
      games = savedGames;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedGames.length == 0) {
        getGames();
      }
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
    print('getting games');
    if (append == false) {
      setState(() {
        fetchingGme = true;
      });
    }
    try {
      http.Response response = await http.get(endpointBaseUrl +
          "/game/listGames?limit=8&order_by=$orderBy${lastGameId == null ? "" : "&last_visible_id=$lastGameId"}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        if (data['data']['length'] == 0 && this.games != null) {
          if (this.games.length > 0) {
            Scaffold.of(context).showSnackBar(SnackBar(
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
          savedGames.addAll(games);
        } else {
          this.games = games;
          savedGames.addAll(games);
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
                            style: TextStyle(color: Colors.white)),
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
                      savedGames = [];
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
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : games.length == 0
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
                                  SizedBox(
                                    height: 180,
                                    child: GameCover(
                                      game: games[count],
                                    ),
                                  ),
                                  Container(
                                    height: 15,
                                    width: MediaQuery.of(context).size.width,
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
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.blue[900]),
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
        )),
      ],
    );
  }
}
