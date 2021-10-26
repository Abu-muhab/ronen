import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/widgets/game_cover.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool menuOpen = false;
  List<Game> games;
  bool fetchingGme = false;
  bool isLazyLoading = false;
  int lastVisiblePage = 0;
  TextEditingController queryController = TextEditingController();
  int numberOfPages;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() async {
      if ((scrollController.position.pixels + 1) >=
          scrollController.position.maxScrollExtent) {
        if (isLazyLoading == true) {
          return;
        }
        if (numberOfPages != null) {
          if (lastVisiblePage == numberOfPages - 1) {
            return;
          }
        }
        if (isLazyLoading == false) {
          setState(() {
            isLazyLoading = true;
          });
          lastVisiblePage++;
          await getGames(append: true, query: queryController.text.trim());
          setState(() {
            isLazyLoading = false;
          });
        }
      }
    });
  }

  Future<void> getGames(
      {bool append = false, String query, bool refresh = false}) async {
    if (query == "") {
      return;
    }
    if (append == false) {
      setState(() {
        fetchingGme = true;
      });
    }
    try {
      http.Response response = await http.get(Uri.parse(endpointBaseUrl +
          "/game/searchGames?&query=$query&page=$lastVisiblePage&hitsPerPage=8"));
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        print(data);
        List rawGames = data['data']['games'];
        numberOfPages = data['data']['numberOfPages'];
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
      if (append == true) {
        lastVisiblePage--;
      }
      if (append == false) {
        setState(() {
          fetchingGme = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: kToolbarHeight + 10,
        backgroundColor: Color.fromRGBO(0, 0, 20, 1),
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          controller: queryController,
          style: TextStyle(fontSize: 15, height: 1.3, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Ronin",
            hintStyle:
                TextStyle(fontSize: 15, height: 1.3, color: Colors.grey[700]),
            contentPadding: EdgeInsets.only(left: 10, right: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.transparent, width: 0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.transparent, width: 0)),
            filled: true,
            fillColor: kAccentColor,
          ),
          onSubmitted: (val) {
            if (val.trim() != "") {
              lastVisiblePage = 0;
              games = null;
              getGames(query: val.trim());
            }
          },
        ),
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
              child: games == null &&
                      fetchingGme == false &&
                      queryController.text == ""
                  ? GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                        color: kPrimaryColorLight,
                      ),
                    )
                  : (games == null && fetchingGme == true) ||
                          (games != null &&
                              fetchingGme == true &&
                              lastVisiblePage == 0)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : games == null && fetchingGme == false
                          ? Center(
                              child: RaisedButton(
                                color: Colors.blueAccent,
                                onPressed: () {
                                  getGames(query: queryController.text.trim());
                                },
                                child: Text('Retry',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          : games.length == 0
                              ? Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      "The term you entered did not bring up any results",
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
                                              key: new GlobalKey(),
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
                                                                Colors
                                                                    .blue[900]),
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
                                    lastVisiblePage = 0;
                                    games = null;
                                    await getGames(
                                        query: queryController.text.trim());
                                  }),
            ))
          ],
        ),
      ),
    );
  }
}
