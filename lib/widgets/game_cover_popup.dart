import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/api/payment_api.dart';
import 'package:ronen/api/user.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/providers/auth.dart';
import 'package:ronen/util.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

class GameCoverPopup extends StatefulWidget {
  final Game game;

  GameCoverPopup({this.game});
  @override
  State createState() => GameCoverPopupState();
}

class GameCoverPopupState extends State<GameCoverPopup> {
  bool showLoadingIndicator = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.game.name,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.game.imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                showLoadingIndicator == true
                    ? LinearProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            kPrimaryColorDark),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            widget.game.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blueAccent,
                                  size: 12,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  convertTimeStampToString(
                                      widget.game.releaseDate),
                                  style: TextStyle(
                                      color: Colors.blueAccent, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.game.description,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RaisedButton(
                            onPressed: () async {
                              setState(() {
                                showLoadingIndicator = true;
                              });
                              UserApi.addToBookmarks(
                                      userId: Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .firebaseUser
                                          .uid,
                                      gameId: widget.game.gameId)
                                  .then((value) {
                                setState(() {
                                  showLoadingIndicator = false;
                                });
                                if (value == true) {
                                  showBasicMessageDialog(
                                      "Added to Bookmarks", context);
                                }
                              }).catchError((err) {
                                setState(() {
                                  showLoadingIndicator = false;
                                });
                                showBasicMessageDialog(err.toString(), context);
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Bookmark',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            color: kPrimaryColorLight,
                          ),
                          RaisedButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.disc_full_sharp,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Borrow CD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            color: Colors.blue[900],
                          ),
                          RaisedButton(
                            onPressed: () {
                              showLoadingDialog(context);
                              PaymentApi.getInstance().then((paymentApi) async {
                                paymentApi
                                    .initializeGamePurchaseTransaction(
                                        context: context,
                                        fee: 500,
                                        gameId: widget.game.gameId)
                                    .then((details) async {
                                  Navigator.pop(context);
                                  CheckoutResponse response =
                                      await paymentApi.beginTransaction(
                                          context: context,
                                          transactionDetails: details);
                                  // if (response.status) {
                                  //   Navigator.popUntil(
                                  //       context, ModalRoute.withName('home'));
                                  // }
                                }).catchError((err) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Text(err.toString()),
                                          actions: [
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("CLOSE"))
                                          ],
                                        );
                                      });
                                });
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Buy CD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            color: Colors.green,
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
