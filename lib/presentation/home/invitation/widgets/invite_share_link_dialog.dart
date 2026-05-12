import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/helper/responsive_helper.dart';
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

      if (success != null) {
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
        formattedExpire = DateFormat('dd MMM yyyy, HH:mm').format(expiredAt);
      } catch (e) {
        debugPrint('Error parsing expired_at: $e');
        formattedExpire = expiredAtStr;
      }
    } else if (isNoExpired) {
      formattedExpire = '-';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(context, 16)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rh(context, 16)),
        constraints: BoxConstraints(maxWidth: rw(context, 450)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invite Share Link',
                    style: TextStyle(
                      fontSize: rfs(context, 18),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF263238),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: rw(context, 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            vSpace(context, 12),
            const Divider(height: 1),
            vSpace(context, 16),

            // Tab Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF005596),
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: const Color(0xFF005596),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: rfs(context, 14),
                ),
                tabs: const [
                  Tab(text: 'Invite Via Link'),
                  Tab(text: 'Invite Via Email'),
                ],
              ),
            ),
            vSpace(context, 24),

            // Tab Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: SizedBox(
                height: rh(context, 240),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInviteViaLink(
                      context,
                      url,
                      formattedExpire,
                      expiredAt,
                      isNoExpired,
                    ),
                    _buildInviteViaEmail(
                      context,
                      formattedExpire,
                      expiredAt,
                      isNoExpired,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteViaLink(
    BuildContext context,
    String url,
    String expire,
    DateTime? expiredAt,
    bool isNoExpired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share this link to invite users:',
          style: TextStyle(
            fontSize: rfs(context, 14),
            color: const Color(0xFF607D8B),
            fontWeight: FontWeight.w500,
          ),
        ),
        vSpace(context, 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(rw(context, 10)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 14),
              vertical: rh(context, 16),
            ),
            child: Text(
              url,
              style: TextStyle(
                fontSize: rfs(context, 13),
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        vSpace(context, 16),
        // Expiration + Countdown Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The invitation expires in:',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: const Color(0xFF78909C),
                    ),
                  ),
                  vSpace(context, 2),
                  Text(
                    expire,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            if (isNoExpired)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 10),
                  vertical: rh(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(rw(context, 6)),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      size: rw(context, 14),
                      color: Colors.blue.shade800,
                    ),
                    hSpace(context, 6),
                    Text(
                      'No Expired',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              )
            else if (expiredAt != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 10),
                  vertical: rh(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(rw(context, 6)),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: rw(context, 14),
                      color: Colors.orange.shade800,
                    ),
                    hSpace(context, 6),
                    Text(
                      _getRemainingTime(expiredAt),
                      style: TextStyle(
                        fontSize: rfs(context, 12),
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
          height: rh(context, 50),
          child: ElevatedButton(
            onPressed: () {
              final String agenda = widget.item['agenda'] ?? '-';
              final String visitorTypeId = widget.item['visitor_type_id']?.toString() ?? '';
              
              String visitorTypeName = '-';
              if (visitorTypeId.isNotEmpty) {
                try {
                  final type = controller.visitorTypes.firstWhere(
                    (v) => v['id'].toString() == visitorTypeId,
                    orElse: () => <String, dynamic>{},
                  );
                  visitorTypeName = type['name'] ?? type['visitor_type_name'] ?? '-';
                } catch (_) {
                  visitorTypeName = '-';
                }
              }

              String formatDateTime(String? dateStr) {
                if (dateStr == null) return '-';
                try {
                  String normalized = dateStr;
                  if (!normalized.endsWith('Z') && !normalized.contains('+')) {
                    normalized = '${normalized.replaceFirst(' ', 'T')}Z';
                  }
                  final date = DateTime.parse(normalized).toLocal();
                  return DateFormat('dd MMM yyyy, HH:mm').format(date);
                } catch (e) {
                  return dateStr;
                }
              }

              final String start = formatDateTime(widget.item['visitor_period_start']);
              final String end = formatDateTime(widget.item['visitor_period_end']);

              final String shareText = "*Agenda* : $agenda\n"
                  "*Visitor Type* : $visitorTypeName\n"
                  "*Start* : $start - $end\n"
                  "*Link Expired* : $expire\n\n"
                  "Untuk bergabung ke undangan klik link di bawah ini:\n$url";

              Clipboard.setData(ClipboardData(text: shareText));
              Get.snackbar(
                'Success',
                'Invitation details copied to clipboard',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: EdgeInsets.all(rw(context, 16)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rw(context, 10)),
              ),
            ),
            child: Text(
              'Copy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: rfs(context, 15),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteViaEmail(
    BuildContext context,
    String expire,
    DateTime? expiredAt,
    bool isNoExpired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter email address to send invitation:',
          style: TextStyle(
            fontSize: rfs(context, 14),
            color: const Color(0xFF607D8B),
            fontWeight: FontWeight.w500,
          ),
        ),
        vSpace(context, 12),
        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          style: TextStyle(fontSize: rfs(context, 14)),
          decoration: InputDecoration(
            hintText: 'Input your email',
            hintStyle: TextStyle(
              fontSize: rfs(context, 14),
              color: Colors.grey.shade400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: rw(context, 16),
              vertical: rh(context, 14),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: const BorderSide(
                color: Color(0xFF005596),
                width: 1.5,
              ),
            ),
          ),
        ),
        vSpace(context, 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The invitation expires in:',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: const Color(0xFF78909C),
                    ),
                  ),
                  vSpace(context, 2),
                  Text(
                    expire,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            if (isNoExpired)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 10),
                  vertical: rh(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(rw(context, 6)),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      size: rw(context, 14),
                      color: Colors.blue.shade800,
                    ),
                    hSpace(context, 6),
                    Text(
                      'No Expired',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              )
            else if (expiredAt != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 10),
                  vertical: rh(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(rw(context, 6)),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: rw(context, 14),
                      color: Colors.orange.shade800,
                    ),
                    hSpace(context, 6),
                    Text(
                      _getRemainingTime(expiredAt),
                      style: TextStyle(
                        fontSize: rfs(context, 12),
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
          height: rh(context, 50),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendEmailAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rw(context, 10)),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: rw(context, 24),
                    height: rw(context, 24),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Send Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: rfs(context, 15),
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
