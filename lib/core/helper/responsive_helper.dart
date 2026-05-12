import 'package:flutter/material.dart';

/// Gold Standard Responsive Helper based on iPhone 15 Pro Max (430x932)
/// This ensures UI scales perfectly across all devices.

/// Responsive font size based on width
double rfs(BuildContext context, double size) {
  final w = MediaQuery.of(context).size.width;
  // Base width 430 for iPhone 15 Pro Max
  return size * (w / 430);
}

/// Responsive width
double rw(BuildContext context, double width) {
  final w = MediaQuery.of(context).size.width;
  return width * (w / 430);
}

/// Responsive height 
double rh(BuildContext context, double height) {
  final h = MediaQuery.of(context).size.height;
  return height * (h / 932);
}

/// Horizontal spacing
Widget hSpace(BuildContext context, double width) => SizedBox(width: rw(context, width));

/// Vertical spacing
Widget vSpace(BuildContext context, double height) => SizedBox(height: rh(context, height));
