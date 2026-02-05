import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/core.dart';

class EvacuateOverlay extends StatefulWidget {
  final VoidCallback onCheckin;
  final Duration? initialDuration;

  const EvacuateOverlay({
    super.key,
    required this.onCheckin,
    this.initialDuration,
  });

  @override
  State<EvacuateOverlay> createState() => _EvacuateOverlayState();
}

class _EvacuateOverlayState extends State<EvacuateOverlay> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Use provided duration or default to 2 minutes
    _duration = widget.initialDuration ?? const Duration(minutes: 2);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _duration.inSeconds > 0) {
        setState(() {
          _duration = _duration - const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.blocked.withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "EVACUATE",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(_duration),
            style: TextStyle(
              fontSize: 20,
              color: _duration.inSeconds <= 30 ? Colors.red : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            child: Assets.images.fakeQr.image(height: 300, width: 300),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Immediately go to\n the assembly point",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onCheckin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Checkin Evacuate",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
