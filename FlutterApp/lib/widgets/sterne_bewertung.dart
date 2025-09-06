import 'package:flutter/material.dart';

class SterneBewertung extends StatelessWidget {
  final double rating;
  final double iconSize;
  final double fontSize;
  final Color textColor;
  final Color iconColor;

  const SterneBewertung({
    super.key,
    required this.rating,
    this.iconSize = 16,
    this.fontSize = 16,
    this.textColor = Colors.grey,
    this.iconColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = List.generate(5, (index) {
      return borderedStarIcon(
        iconSize: iconSize,
        iconColor: (rating >= index + 0.75)
            ? iconColor
            : (rating >= index + 0.25)
                ? iconColor.withOpacity(0.5)
                : Colors.transparent,
      );
    });

    return Row(children: stars);
  }

  Widget borderedStarIcon(
      {required double iconSize, required Color iconColor}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.star, color: Colors.black, size: iconSize),
        Icon(Icons.star, color: iconColor, size: iconSize - 5), // border effect
      ],
    );
  }
}
