import 'package:flutter/material.dart';

class CustomCircleImage extends StatelessWidget {
  final Widget image;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final double scale;

  const CustomCircleImage({
    super.key,
    required this.image,
    this.size = 36.0,
    this.borderWidth = 1.0,
    this.borderColor = Colors.white,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Transform.scale(
          scale: scale,
          child: image,
        ),
      ),
    );
  }
}
