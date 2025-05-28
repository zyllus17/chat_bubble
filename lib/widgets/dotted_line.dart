import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final double strokeWidth;
  final Color color;

  const DottedLine({
    super.key,
    this.height = 1,
    this.strokeWidth = 1,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color,
            width: strokeWidth,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}
