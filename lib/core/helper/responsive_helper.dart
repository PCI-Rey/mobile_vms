import 'package:flutter/material.dart';

/// Responsive font size helper
/// Base width = 390 (iPhone 14/15 standard). 
/// Clamps 0.8–1.3x so tiny phones don't go too small 
/// and huge tablets don't go wild.
double rfs(BuildContext context, double size) {
  final w = MediaQuery.of(context).size.width;
  return size * (w / 390).clamp(0.8, 1.3);
}
