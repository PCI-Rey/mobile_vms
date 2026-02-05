import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/core.dart';
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
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
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

  String? _getSubText(Duration duration) {
    return null; // Tidak ada sub text untuk timer detik
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
      width: 45,
      height: 45,
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
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    // Bagian 1: Parking Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              height: screenHeight * 0.15,
                              child: Assets.images.parkingSlot.image(
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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

                    const SizedBox(height: 20),

                    // Bagian 2: Denah Parkir
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Baris pertama slot parkir
                          Row(
                            children: [
                              Expanded(child: _slotBox('A1', active: true)),
                              const SizedBox(width: 8),
                              Expanded(child: _slotBox('A3')),
                            ],
                          ),
                          
                          // Jalan tengah dengan panah
                          Container(
                            height: 40,
                            child: Center(
                              child: Assets.images.arrowVector.image(
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          // Baris kedua slot parkir
                          Row(
                            children: [
                              Expanded(child: _slotBox('A2', active: false)),
                              const SizedBox(width: 8),
                              Expanded(child: _slotBox('A4')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Extra space untuk memberikan jarak ke bottom
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, -2),
                    blurRadius: 8,
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

                  const SizedBox(height: 12),

                  // Bagian 4: Control Gate
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
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
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Control Gate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildTimerWidget(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10)
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
      height: 45, // Fixed height yang lebih kecil
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}