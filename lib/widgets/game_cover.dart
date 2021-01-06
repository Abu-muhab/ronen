import 'package:flutter/material.dart';
import 'package:ronen/widgets/game_cover_popup.dart';

class GameCover extends StatefulWidget {
  final String asset;
  final String name;
  GameCover({this.asset, this.name});
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
                    name: widget.name,
                    asset: widget.asset,
                  ),
                );
              });
        },
        child: Row(
          children: [
            Expanded(child: Image.asset(widget.asset, fit: BoxFit.cover)),
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
