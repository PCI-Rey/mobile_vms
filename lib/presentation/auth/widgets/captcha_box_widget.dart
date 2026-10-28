import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/helper/responsive_helper.dart';

class CaptchaBoxWidget extends StatefulWidget {
  final String captchaCode;
  final String? captchaSvg;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final TextEditingController controller;
  final String? errorText;
  final double sw;

  const CaptchaBoxWidget({
    super.key,
    required this.captchaCode,
    this.captchaSvg,
    required this.isRefreshing,
    required this.onRefresh,
    required this.controller,
    required this.sw,
    this.errorText,
  });

  @override
  State<CaptchaBoxWidget> createState() => _CaptchaBoxWidgetState();
}

class _CaptchaBoxWidgetState extends State<CaptchaBoxWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant CaptchaBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !oldWidget.isRefreshing) {
      _spinController.repeat();
    } else if (!widget.isRefreshing && oldWidget.isRefreshing) {
      _spinController.stop();
      _spinController.reset();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleRefreshTap() {
    _spinController.forward(from: 0.0);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;

    // Palette colors for captcha characters to match Web VMS
    const characterColors = [
      Color(0xFF0F2B48), // Deep Navy
      Color(0xFF1976D2), // BI Blue
      Color(0xFF0284C7), // Cerulean
      Color(0xFF1E293B), // Slate Dark
      Color(0xFF0369A1), // Ocean Blue
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label
        Padding(
          padding: EdgeInsets.only(left: sw * 0.01, bottom: sw * 0.015),
          child: Text(
            'captcha'.tr,
            style: TextStyle(
              fontSize: rfs(context, 13.5),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
        ),

        // 2. Row: Captcha Image Container + Refresh Button
        Row(
          children: [
            // Captcha Box Display
            Expanded(
              child: Container(
                height: sw * 0.115,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.028),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sw * 0.028),
                  child: Stack(
                    children: [
                      if (widget.isRefreshing)
                        const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        )
                      else ...[
                        // 1. Background layer: SVG vector background from backend or noise painter
                        if (widget.captchaSvg != null &&
                            widget.captchaSvg!.isNotEmpty)
                          Positioned.fill(
                            child: SvgPicture.string(
                              widget.captchaSvg!,
                              fit: BoxFit.fill,
                            ),
                          )
                        else
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CaptchaNoisePainter(
                                seed: widget.captchaCode.hashCode,
                              ),
                            ),
                          ),

                        // Overlay light noise distortion to match bank security standard
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CaptchaNoisePainter(
                              seed: widget.captchaCode.hashCode,
                            ),
                          ),
                        ),

                        // 2. Character layer: Native high-DPI text renderer with slight tilt & colors
                        Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              widget.captchaCode.length,
                              (index) {
                                final char = widget.captchaCode[index];
                                final color = characterColors[
                                    index % characterColors.length];
                                final angle = math.sin(
                                        (widget.captchaCode.hashCode +
                                                index) *
                                            1.7) *
                                    0.16;

                                return Transform.rotate(
                                  angle: angle,
                                  child: Text(
                                    char,
                                    style: TextStyle(
                                      fontSize: rfs(context, 19.5),
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.022),

            // Refresh Button (Square container)
            InkWell(
              onTap: widget.isRefreshing ? null : _handleRefreshTap,
              borderRadius: BorderRadius.circular(sw * 0.028),
              child: Container(
                width: sw * 0.115,
                height: sw * 0.115,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(sw * 0.028),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _spinController,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: const Color(0xFF1976D2),
                      size: sw * 0.052,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: sw * 0.018),

        // 3. Captcha Input Field
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
            fontSize: rfs(context, 13.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: 'captcha_hint'.tr,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: rfs(context, 13.5),
              fontWeight: FontWeight.normal,
              letterSpacing: 0,
            ),
            prefixIcon: Icon(
              Icons.shield_outlined,
              color: const Color(0xFF1976D2),
              size: sw * 0.048,
            ),
            filled: true,
            fillColor: const Color(0xFFF4F7FB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.038,
              vertical: sw * 0.032,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 1.5,
              ),
            ),
            errorText: widget.errorText,
            errorStyle: const TextStyle(height: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to generate realistic captcha background noise & scratch lines
class _CaptchaNoisePainter extends CustomPainter {
  final int seed;

  _CaptchaNoisePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);

    // 1. Draw subtle scratch/wave lines
    final linePaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 2; i++) {
      final path = Path();
      path.moveTo(0, random.nextDouble() * size.height);
      path.quadraticBezierTo(
        size.width * 0.5,
        random.nextDouble() * size.height,
        size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawPath(path, linePaint);
    }

    // 2. Draw speckled dots
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.8 + random.nextDouble() * 1.4;
      final isBlue = random.nextBool();

      dotPaint.color = isBlue
          ? const Color(0xFF1976D2).withValues(alpha: 0.20)
          : const Color(0xFF64748B).withValues(alpha: 0.25);

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaNoisePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
