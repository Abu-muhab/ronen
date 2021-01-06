import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/widgets/decorated_icon.dart';
import 'package:ronen/widgets/game_cover.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool menuOpen = false;

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
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      child: Text('Hours',
                                          style:
                                              TextStyle(color: Colors.white)))
                                ],
                                onChanged: (slected) {},
                                dropdownColor: Colors.blueAccent,
                                elevation: 5,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Choose',
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
                                      child: Text('All',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      child: Text('Availabe',
                                          style:
                                              TextStyle(color: Colors.white)))
                                ],
                                onChanged: (slected) {},
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
                          child: Padding(
                        padding: EdgeInsets.all(0),
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            SizedBox(
                              height: 180,
                              child: GameCover(
                                asset: 'images/halo.jpg',
                                name: 'Halo',
                              ),
                            ),
                            Container(
                              height: 15,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimaryColorDark,
                            ),
                            SizedBox(
                              height: 180,
                              child: GameCover(
                                asset: 'images/creed.jpg',
                                name: "Assasin's Creed",
                              ),
                            ),
                            Container(
                              height: 15,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimaryColorDark,
                            ),
                            SizedBox(
                              height: 180,
                              child: GameCover(
                                asset: 'images/war.jpg',
                                name: "God of War",
                              ),
                            ),
                            Container(
                              height: 15,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimaryColorDark,
                            ),
                            SizedBox(
                              height: 180,
                              child: GameCover(
                                  asset: 'images/bow.jpg', name: 'Templar'),
                            ),
                            Container(
                              height: 15,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimaryColorDark,
                            ),
                            SizedBox(
                              height: 180,
                              child: GameCover(
                                asset: 'images/cod.jpg',
                                name: 'Call of Duty',
                              ),
                            ),
                            Container(
                              height: 15,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimaryColorDark,
                            ),
                          ],
                        ),
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
