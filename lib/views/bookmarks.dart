import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/providers/auth.dart';
import 'package:ronen/widgets/game_cover.dart';
import 'package:http/http.dart' as http;

class Bookmarks extends StatefulWidget {
  Bookmarks({Key key}) : super(key: key);

  @override
  BookmarksState createState() => BookmarksState();
}

List<Game> savedGames = [];
double savedScrollOffset;

class BookmarksState extends State<Bookmarks> {
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<Game> games;
  bool fetchingGme = true;

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
  }

  Future<void> getGames() async {
    print('getting games');
    setState(() {
      fetchingGme = true;
    });
    try {
      http.Response response = await http.get(endpointBaseUrl +
          "/user/bookmarks?userId=${Provider.of<AuthProvider>(context, listen: false).firebaseUser.uid}");
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        List rawGames = data['data']['games'];
        List<Game> games;
        games = rawGames.map((e) {
          return Game.fromJson(e);
        }).toList();
        this.games = games;
        savedGames = games;
      }
      setState(() {
        fetchingGme = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingGme = false;
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
    );
  }
}
