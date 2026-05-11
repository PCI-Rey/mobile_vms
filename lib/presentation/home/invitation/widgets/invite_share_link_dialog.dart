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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final String url = widget.item['url'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invite Visitor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF005596),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF005596),
              tabs: const [
                Tab(text: 'Invite via Link'),
                Tab(text: 'Invite via Email'),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInviteViaLink(url),
                    _buildInviteViaEmail(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteViaLink(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share this link to invite users:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Get.snackbar(
                    'Success',
                    'Link copied to clipboard',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                child: const Icon(
                  Icons.copy,
                  size: 18,
                  color: Color(0xFF005596),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Get.snackbar(
                'Success',
                'Link copied to clipboard',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text(
              'COPY LINK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF005596),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteViaEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter email address to send invitation:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Input your email',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF005596)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendEmailAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'SEND INVITATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
