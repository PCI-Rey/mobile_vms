import 'package:flutter/material.dart';

class CustomCircleImage extends StatelessWidget {
  final Widget image;
  final double size;
  final double borderWidth;
  final Color borderColor;

  const CustomCircleImage({
    super.key,
    required this.image,
    this.size = 36.0,
    this.borderWidth = 1.0,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF666666)],
        ),
      ),
      child: ClipOval(child: image),
    );
  }
}
