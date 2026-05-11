import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/invitation_controller.dart';

class InviteShareLinkDialog extends StatefulWidget {
  final dynamic item;
  const InviteShareLinkDialog({super.key, required this.item});

  @override
  State<InviteShareLinkDialog> createState() => _InviteShareLinkDialogState();
}

class _InviteShareLinkDialogState extends State<InviteShareLinkDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final InvitationController controller = Get.find<InvitationController>();
  bool _isLoading = false;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startAutoCloseTimer();
  }

  void _startAutoCloseTimer() {
    final expiredAtStr = widget.item['expired_at'];
    if (expiredAtStr == null) return;

    String normalized = expiredAtStr.toString();
    if (!normalized.endsWith('Z') && !normalized.contains('+')) {
      normalized = '${normalized.replaceFirst(' ', 'T')}Z';
    }
    final expiredAt = DateTime.tryParse(normalized)?.toLocal();
    if (expiredAt == null) return;

    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh UI every second for countdown
      }

      if (DateTime.now().isAfter(expiredAt)) {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          Get.snackbar(
            'Link Expired',
            'This link has just expired and can no longer be shared.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendEmailAction() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build body exactly as requested by user
      final Map<String, dynamic> body = {
        'host': widget.item['host'],
        'agenda': widget.item['agenda'],
        'visitor_type_id': widget.item['visitor_type_id'],
        'site_id': widget.item['site_id'],
        'visitor_period_start': widget.item['visitor_period_start'],
        'visitor_period_end': widget.item['visitor_period_end'],
        'link_active_at': widget.item['active_at'],
        'expired_number': widget.item['expired_number'],
        'max_usage': widget.item['max_usage'],
        'is_single_use': widget.item['is_single_use'] ?? false,
        'tz': widget.item['tz'] ?? 'Asia/Jakarta',
        'emails': [_emailController.text.trim()],
      };

      final success = await controller.createShareLinkAction(
        body,
        sendEmail: true,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Invitation sent to ${_emailController.text}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (mounted) Navigator.pop(context);
      } else {
        Get.snackbar(
          'Error',
          'Failed to send invitation',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getRemainingTime(DateTime expiredAt) {
    final difference = expiredAt.difference(DateTime.now());
    if (difference.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(difference.inHours)}:${twoDigits(difference.inMinutes.remainder(60))}:${twoDigits(difference.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final int expiredNumber = widget.item['expired_number'] ?? -1;
    final bool isNoExpired = expiredNumber == 0;
    
    final String url = widget.item['url'] ?? '';
    final String expiredAtStr = widget.item['expired_at']?.toString() ?? '';
    DateTime? expiredAt;
    String formattedExpire = '-';

    if (!isNoExpired && expiredAtStr.isNotEmpty) {
      try {
        String normalized = expiredAtStr;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        expiredAt = DateTime.parse(normalized).toLocal();
        final months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        formattedExpire = '${expiredAt.day} ${months[expiredAt.month]} ${expiredAt.year}, ${expiredAt.hour.toString().padLeft(2, '0')}.${expiredAt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    } else if (isNoExpired) {
      formattedExpire = '-'; // Or 'Never'
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Invite Share Link',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Tab Header
            Center(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF005596),
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: const Color(0xFF005596),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: const [
                  Tab(text: 'Invite Via Link'),
                  Tab(text: 'Invite Via Email'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 220,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInviteViaLink(url, formattedExpire, expiredAt, isNoExpired),
                    _buildInviteViaEmail(formattedExpire, expiredAt, isNoExpired),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteViaLink(String url, String expire, DateTime? expiredAt, bool isNoExpired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share this link to invite users:',
          style: TextStyle(fontSize: 14, color: Color(0xFF607D8B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text(
              url,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey.shade700,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Expiration + Countdown Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The invitation expires in:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expire,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                ],
              ),
            ),
            if (isNoExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.all_inclusive, size: 14, color: Colors.blue.shade800),
                    const SizedBox(width: 6),
                    Text(
                      'No Expired',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              )
            else if (expiredAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Text(
                      _getRemainingTime(expiredAt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Get.snackbar(
                'Success',
                'Link copied to clipboard',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Copy Link',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteViaEmail(String expire, DateTime? expiredAt, bool isNoExpired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter email address to send invitation:',
          style: TextStyle(fontSize: 14, color: Color(0xFF607D8B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Input your email',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF005596), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The invitation expires in:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expire,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                ],
              ),
            ),
            if (isNoExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.all_inclusive, size: 14, color: Colors.blue.shade800),
                    const SizedBox(width: 6),
                    Text(
                      'No Expired',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              )
            else if (expiredAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Text(
                      _getRemainingTime(expiredAt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendEmailAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Send Invitation',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5),
                  ),
          ),
        ),
      ],
    );
  }
}
