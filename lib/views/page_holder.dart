import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/providers/auth.dart';
import 'package:ronen/views/bookmarks.dart';
import 'package:ronen/views/games.dart';
import 'package:ronen/views/home.dart';
import 'package:ronen/widgets/decorated_icon.dart';

class PageHolder extends StatefulWidget {
  PageHolder({Key key}) : super(key: key);

  @override
  PageHolderState createState() => PageHolderState();
}

class PageHolderState extends State<PageHolder> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool menuOpen = false;
  String title = 'Ronen';
  int pageIndex = 0;

  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (tabController.index == 0) {
        setState(() {
          title = "Ronen";
          pageIndex = tabController.index;
        });
      } else if (tabController.index == 1) {
        setState(() {
          title = "My Games";
          pageIndex = tabController.index;
        });
      } else if (tabController.index == 2) {
        setState(() {
          title = "Wishlist";
          pageIndex = tabController.index;
        });
      }
    });
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
                  title: Text(title),
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
                      Expanded(
                          child: TabBarView(
                        controller: tabController,
                        children: [
                          Home(),
                          MyGames(),
                          Bookmarks(),
                        ],
                      )),
                      Container(
                        height: kToolbarHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                tabController.animateTo(0);
                              },
                              child: Icon(
                                Icons.home,
                                color: pageIndex == 0
                                    ? Colors.blueAccent
                                    : Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                tabController.animateTo(1);
                              },
                              child: Icon(
                                Icons.videogame_asset_outlined,
                                color: pageIndex == 1
                                    ? Colors.blueAccent
                                    : Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                tabController.animateTo(2);
                              },
                              child: Icon(
                                Icons.list_alt_outlined,
                                color: pageIndex == 2
                                    ? Colors.blueAccent
                                    : Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.notifications_none_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
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
                    // DecoratedIcon(
                    //   iconData: Icons.home,
                    //   width: 50,
                    //   backgroundColor: Colors.blueAccent,
                    //   iconColor: Colors.white,
                    // ),
                    // SizedBox(
                    //   height: 50,
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'profile');
                      },
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'settings');
                      },
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .signout();
                      },
                      child: Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                      ),
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
