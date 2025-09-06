import 'package:flutter/material.dart';

BoxDecoration getBoxDeco(double radius, Color color) {
  return BoxDecoration(
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(radius),
      color: color);
}

const light = Color.fromARGB(255, 242, 242, 242);
