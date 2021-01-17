import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/models/game.dart';
import 'package:ronen/widgets/game_cover_popup.dart';

class GameCover extends StatefulWidget {
  final Game game;
  GameCover({this.game, Key key}) : super(key: key);
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
      );
    });
  }
}
