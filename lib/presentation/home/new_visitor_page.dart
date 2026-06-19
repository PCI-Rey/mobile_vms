// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';
import '../../data/models/access_pass_model.dart';
import '../auth/controller/language_controller.dart';
import 'invitation/controller/invitation_controller.dart';

class NewVisitorPage extends StatefulWidget {
  const NewVisitorPage({super.key});

  @override
  State<NewVisitorPage> createState() => _NewVisitorPageState();
}

class _NewVisitorPageState extends State<NewVisitorPage> {
  late final InvitationController invitationController;
  late final LanguageController langCtrl;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InvitationController>()) {
      invitationController = Get.find<InvitationController>();
    } else {
      invitationController = Get.put(InvitationController());
    }
    langCtrl = LanguageController.to;
  }

  Map<String, Color> _getBadgeColors(String status) {
    final lower = status.toLowerCase().trim();
    if (lower == 'checkin') {
      return {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF2E7D32),
      };
    } else if (lower == 'checkout') {
      return {
        'bg': const Color(0xFFE8EAF6),
        'text': const Color(0xFF283593),
      };
    } else if (lower == 'pending' || lower == 'waiting') {
      return {
        'bg': const Color(0xFFFFF3E0),
        'text': const Color(0xFFEF6C00),
      };
    } else if (lower == 'reject' || lower == 'rejected' || lower == 'denied' || lower == 'deny') {
      return {
        'bg': const Color(0xFFFFEBEE),
        'text': const Color(0xFFC62828),
      };
    } else {
      // Active, Available, or others
      return {
        'bg': const Color(0xFFE0F7FA),
        'text': const Color(0xFF006064),
      };
    }
  }

  String _displayStatus(String status) {
    final lowerStatus = status.toLowerCase().trim();
    if (lowerStatus == 'available') {
      return 'Available';
    } else if (lowerStatus == 'pending' || lowerStatus == 'waiting') {
      return 'Pending';
    } else if (lowerStatus == 'undercreated') {
      return 'Under Created';
    } else if (lowerStatus == 'checkin') {
      return 'Checked In';
    } else if (lowerStatus == 'checkout') {
      return 'Checked Out';
    } else if (lowerStatus == 'reject' ||
        lowerStatus == 'rejected' ||
        lowerStatus == 'denied' ||
        lowerStatus == 'deny') {
      return 'Rejected';
    } else if (lowerStatus == 'preregis' ||
        lowerStatus == 'praregis' ||
        lowerStatus == 'praregister') {
      return 'Praregis';
    } else if (lowerStatus == 'quickaccess') {
      return 'Quick Access';
    } else if (status.isNotEmpty) {
      return status[0].toUpperCase() + status.substring(1);
    }
    return 'Active';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          final isId = langCtrl.selectedLang.value == 'id';
          return Text(
            isId ? 'Visitor Terbaru' : 'New Visitor',
            style: TextStyle(
              fontSize: rfs(context, 22),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          );
        }),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(
            color: AppColors.grey300,
            height: rh(context, 1.0),
          ),
        ),
      ),
      body: Obx(() {
        final date = invitationController.selectedDashboardDate.value;
        final isId = langCtrl.selectedLang.value == 'id';

        // Get today's individual visitors from controller (reactive cached list)
        final List<AccessPassModel> newVisitors = invitationController.getTodayVisitors();

        if (newVisitors.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 24),
                vertical: rh(context, 32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: rw(context, 64),
                    color: Colors.grey.shade400,
                  ),
                  vSpace(context, 16),
                  Text(
                    isId ? 'Tidak ada visitor baru hari ini' : 'No new visitors today',
                    style: TextStyle(
                      fontSize: rfs(context, 15),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(
            left: rw(context, 16),
            right: rw(context, 16),
            top: rh(context, 16),
            bottom: rh(context, 16) + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: newVisitors.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.shade100,
            indent: rw(context, 76),
          ),
          itemBuilder: (context, index) {
            final visitor = newVisitors[index];
            final isLast = index == newVisitors.length - 1;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: index == 0 ? const Radius.circular(16) : Radius.zero,
                  topRight: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildVisitorRow(context, visitor, index),
            );
          },
        );
      }),
    );
  }

  Widget _buildVisitorRow(BuildContext context, AccessPassModel visitor, int index) {
    final timeStr = DateFormat('HH:mm').format(visitor.invitationCreatedAt ?? visitor.visitorPeriodStart);
    final badgeColors = _getBadgeColors(visitor.visitorStatus);
    final displayStatus = _displayStatus(visitor.visitorStatus);

    final initials = visitor.visitorName.trim().isNotEmpty
        ? visitor.visitorName.trim()[0].toUpperCase()
        : 'V';

    final colors = [
      const Color(0xFF1976D2), // Blue
      const Color(0xFF388E3C), // Green
      const Color(0xFFD32F2F), // Red
      const Color(0xFFF57C00), // Orange
      const Color(0xFF7B1FA2), // Purple
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 44),
            height: rw(context, 44),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 16),
                ),
              ),
            ),
          ),
          hSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  visitor.visitorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13.5),
                    color: Colors.black87,
                  ),
                ),
                vSpace(context, 4),
                Text(
                  visitor.visitorOrganizationName.isEmpty ? '-' : visitor.visitorOrganizationName,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hSpace(context, 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 8),
                  vertical: rh(context, 4),
                ),
                decoration: BoxDecoration(
                  color: badgeColors['bg'],
                  borderRadius: BorderRadius.circular(rw(context, 20)),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    fontWeight: FontWeight.bold,
                    color: badgeColors['text'],
                  ),
                ),
              ),
              vSpace(context, 6),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
