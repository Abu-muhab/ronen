import 'package:flutter/material.dart';

class DecoratedIcon extends StatelessWidget {
  final double width;
  final IconData iconData;
  final Color iconColor;
  final Color backgroundColor;
  final double iconSize;
  DecoratedIcon(
      {this.width,
      this.iconData,
      this.iconColor,
      this.backgroundColor,
      this.iconSize});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
            size: iconSize,
          )
        ],
      ),
    );
  }
}
