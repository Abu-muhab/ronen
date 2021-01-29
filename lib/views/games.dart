import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';

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
                Container(),
                Container(),
              ],
            ),
          )),
    );
  }
}
