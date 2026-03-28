import 'package:flutter/material.dart';

Color getEffortColor(String effort) {
  switch (effort.toLowerCase()) {
    case 'high':
      return Colors.redAccent;
    case 'medium':
      return Colors.orangeAccent;
    case 'low':
      return Colors.greenAccent;
    default:
      return Colors.blueAccent;
  }
}
