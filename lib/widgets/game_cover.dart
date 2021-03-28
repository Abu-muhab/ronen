import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/borrow_transaction.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/models/game_purchase_transaction.dart';
import 'package:ronen/views/transaction_details.dart';
import 'package:ronen/widgets/game_cover_popup.dart';

class GameCover extends StatefulWidget {
  final Game game;
  final GamePurchaseTransaction purchaseTransaction;
  final BorrowTransaction borrowTransaction;
  GameCover(
      {this.game, Key key, this.borrowTransaction, this.purchaseTransaction})
      : super(key: key);
  @override
  State createState() => GameCoverState();
}

class GameCoverState extends State<GameCover> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  elevation: 10,
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  content: GameCoverPopup(
                    game: widget.game,
                  ),
                );
              });
        },
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: widget.game.imageUrl,
                        placeholder: (context, url) => Stack(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                    tileMode: TileMode.mirror,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: <Color>[
                                      kPrimaryColorDark,
                                      kPrimaryColorLight,
                                    ]).createShader(bounds);
                              },
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.blue[900]),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          ],
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: constraint.maxHeight,
                      width: 40,
                      color: Colors.blueAccent,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              widget.purchaseTransaction != null
                  ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TransactionDetails(
                                          transaction:
                                              widget.purchaseTransaction,
                                        )));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.credit_card_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Transaction Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                          color: kPrimaryColorLight,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    });
  }
}
