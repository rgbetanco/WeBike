import 'package:flutter/material.dart';

class RoundedMarker extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Color color;
  final Function onPressed;

  const RoundedMarker({
    required this.name,
    required this.height,
    required this.width,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 2),
        color: color,
      ),
      child: TextButton(
        onPressed: () => onPressed(),
        child: Text(
          name,
          style: TextStyle(fontSize: 11, color: Colors.white, height: 1),
        ),
      ),
    );
  }
}
