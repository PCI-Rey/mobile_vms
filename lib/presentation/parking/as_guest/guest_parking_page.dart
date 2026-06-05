import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import 'dart:async';

class GuestParkingPage extends StatefulWidget {
  const GuestParkingPage({super.key});

  @override
  State<GuestParkingPage> createState() => _GuestParkingPageState();
}

class _GuestParkingPageState extends State<GuestParkingPage> {
  Timer? _timer;
  Duration _remainingTime = const Duration(seconds: 60); // 1 menit = 60 detik

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          });
        }
      } else {
        _timer?.cancel();
        _showTimeExpiredDialog();
      }
    });
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Parkir Habis'),
        content: const Text('Waktu parkir Anda telah habis. Silakan perpanjang atau keluar dari area parkir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTimerCompact(Duration duration) {
    int seconds = duration.inSeconds;
    return '${seconds.toString().padLeft(2, '0')}s';
  }

  Color _getTimerColor() {
    if (_remainingTime.inSeconds <= 10) {
      return Colors.red;
    } else if (_remainingTime.inSeconds <= 30) {
      return Colors.orange;
    } else {
      return AppColors.primary500;
    }
  }

  Widget _buildTimerWidget() {
    return Container(
      width: rw(context, 45),
      height: rw(context, 45),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: _getTimerColor(), width: 2),
      ),
      child: Center(
        child: Text(
          _formatTimerCompact(_remainingTime),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getTimerColor(),
            fontSize: rfs(context, 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(rw(context, 16), rh(context, 16), rw(context, 16), 0),
                child: Column(
                  children: [
                    // Bagian 1: Parking Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rw(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Parking Area',
                                      style: TextStyles.bodySmall600,
                                    ),
                                    Text(
                                      'Mon, 19 Jul 2025',
                                      style: TextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '10:00 - 13:00',
                                    style: TextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          vSpace(context, 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                            child: SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.15,
                              child: Assets.images.parkingSlot.image(
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          vSpace(context, 12),
                          Row(
                            children: [
                              Text('Slot A1', style: TextStyles.bodySmall600),
                              const Spacer(),
                              Text(
                                'Reserved',
                                style: TextStyles.bodySmall600.copyWith(
                                  color: AppColors.primary500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    vSpace(context, 20),

                    // Bagian 2: Denah Parkir
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rw(context, 16)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(rw(context, 8)),
                      ),
                      child: Column(
                        children: [
                          // Baris pertama slot parkir
                          Row(
                            children: [
                              Expanded(child: _slotBox('A1', active: true)),
                              hSpace(context, 8),
                              Expanded(child: _slotBox('A3')),
                            ],
                          ),
                          
                          // Jalan tengah dengan panah
                          SizedBox(
                            height: rh(context, 40),
                            child: Center(
                              child: Assets.images.arrowVector.image(
                                height: rh(context, 24),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          // Baris kedua slot parkir
                          Row(
                            children: [
                              Expanded(child: _slotBox('A2', active: false)),
                              hSpace(context, 8),
                              Expanded(child: _slotBox('A4')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Extra space untuk memberikan jarak ke bottom
                    vSpace(context, 16),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Section
            Container(
              padding: EdgeInsets.all(rw(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(0, rh(context, -2)),
                    blurRadius: rw(context, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bagian 3: Tombol Unassign
                  SizedBox(
                    width: double.infinity,
                    child: Button.filled(
                      onPressed: () {},
                      label: 'Unassign',
                    ),
                  ),

                  vSpace(context, 12),

                  // Bagian 4: Control Gate
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(rw(context, 12)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FB),
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: rw(context, 40),
                          height: rw(context, 40),
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            FontAwesomeIcons.p,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        hSpace(context, 12),
                        Expanded(
                          child: Text(
                            'Control Gate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rfs(context, 16),
                            ),
                          ),
                        ),
                        _buildTimerWidget(),
                      ],
                    ),
                  ),
                  vSpace(context, 10)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotBox(String label, {bool? active}) {
    Color color;
    if (active == true) {
      color = AppColors.primary500;
    } else if (active == false) {
      color = Colors.grey.shade300;
    } else {
      color = Colors.white;
    }

    return Container(
      height: rh(context, 45), // Fixed height yang lebih kecil
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 8)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rfs(context, 14),
          ),
        ),
      ),
    );
  }
}