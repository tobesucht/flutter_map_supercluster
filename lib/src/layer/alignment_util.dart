import 'package:flutter/material.dart';

class AlignmentUtil {
  static Offset applyAlignment(
    Offset pos,
    double width,
    double height,
    Alignment alignment,
  ) {
    final x = (pos.dx - (width / 2) + ((width / 2) * alignment.x));
    final y = (pos.dy - (height / 2) + ((height / 2) * alignment.y));
    return Offset(x, y);
  }
}
