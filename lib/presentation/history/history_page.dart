import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import 'controller/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  late final HistoryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HistoryController>()) {
      controller = Get.find<HistoryController>();
    } else {
      controller = Get.put(HistoryController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'History',
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: _buildHistoryContent(),
    );
  }

  Widget _buildHistoryContent() {
    final dummyData = [
      {
        'agenda': 'Visit',
        'status': 'Completed',
        'visitorType': 'Visitor (DKUT)',
        'host': 'Endru',
        'organization': 'Kantor A',
        'flow': 'Praregis',
        'periodStart': '14 Jul 25 10:00',
        'periodEnd': '14 Jul 25 12:00',
      },
      {
        'agenda': 'Meeting',
        'status': 'Completed',
        'visitorType': 'Employee (DKUT)',
        'host': 'Budi',
        'organization': 'Kantor B',
        'flow': 'Invitation',
        'periodStart': '15 Jul 25 13:00',
        'periodEnd': '15 Jul 25 15:00',
      },
      {
        'agenda': 'Interview',
        'status': 'Completed',
        'visitorType': 'Visitor (DKUT)',
        'host': 'Andi',
        'organization': 'Kantor C',
        'flow': 'Praregis',
        'periodStart': '16 Jul 25 09:00',
        'periodEnd': '16 Jul 25 11:00',
      },
      {
        'agenda': 'Training',
        'status': 'Completed',
        'visitorType': 'Employee (DKUT)',
        'host': 'Rina',
        'organization': 'Kantor D',
        'flow': 'Invitation',
        'periodStart': '17 Jul 25 08:00',
        'periodEnd': '17 Jul 25 10:00',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(rw(context, 20.0)),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final data = dummyData[index];
        return Padding(
          padding: EdgeInsets.only(bottom: rh(context, 16.0)),
          child: _buildHistoryCard(index, data),
        );
      },
    );
  }

  Widget _buildHistoryCard(int index, Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: rw(context, 10),
            offset: Offset(0, rh(context, 3)),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 16),
              bottom: rh(context, 12),
            ),
            child: Row(
              children: [
                Container(
                  width: rw(context, 26),
                  height: rw(context, 26),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005596),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hSpace(context, 10),
                Expanded(
                  child: Text(
                    data['agenda']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: rfs(context, 16),
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                hSpace(context, 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 12),
                    vertical: rh(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                  ),
                  child: Text(
                    data['status']!,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Body
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 12),
              bottom: rh(context, 16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.badge_outlined,
                        'Visitor Type',
                        data['visitorType']!,
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.person_outline,
                        'Host',
                        data['host']!,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.business_outlined,
                        'Organization',
                        data['organization']!,
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.timeline,
                        'Flow',
                        data['flow']!,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.login_outlined,
                        'Period Start',
                        data['periodStart']!,
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.logout_outlined,
                        'Period End',
                        data['periodEnd']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: rw(context, 14), color: Colors.grey.shade400),
        hSpace(context, 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              vSpace(context, 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
