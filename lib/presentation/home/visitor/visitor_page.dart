import 'package:flutter/material.dart';
import '../../../../presentation/home/visitor/search_visitor_page.dart';
import '../../../../presentation/home/visitor/visitor_list_page.dart';
import '../../../../presentation/parking/scan_ticket_page.dart';
import 'package:get/get.dart';

import '../../../core/core.dart';
import '../../parking/widgets/custom_action_card.dart';
import '../../parking/widgets/custom_stats_card.dart';
import 'controller/visitor_controller.dart';

class VisitorPage extends StatefulWidget {
  const VisitorPage({super.key});

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  TextEditingController searchController = TextEditingController();
  late final VisitorController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<VisitorController>()) {
      controller = Get.find<VisitorController>();
    } else {
      controller = Get.put(VisitorController());
    }
    controller.loadVisitors();
  }

  // Use controller.visitors to show recent/new visitors
  // For now using the static mock in the code just to match design, but hooking up controller for stats

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text('Visitor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  context.push(SearchVisitorPage());
                },
                child: IgnorePointer(
                  // Mencegah TextField menerima input
                  child: CustomTextField(
                    controller: searchController,
                    label: 'Search',
                    hintText: 'Search',
                    suffixIcon: Icon(Icons.search),
                    showLabel: false,
                    readOnly: true,
                  ),
                ),
              ),

              const SpaceHeight(20),
              Divider(height: 1, thickness: 0.3),
              const SpaceHeight(20),

              // Available Slots and Parked Vehicles using Obx
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomStatCard(
                        title: 'Today Visit',
                        value: controller.todayVisitCount.value.toString(),
                      ),
                    ),
                    const SpaceWidth(16),
                    Expanded(
                      child: CustomStatCard(
                        title: 'Check in',
                        value: controller.checkInCount.value.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomStatCard(
                        title: 'Deny',
                        value: controller.denyCount.value.toString(),
                      ),
                    ),
                    const SpaceWidth(16),
                    Expanded(
                      child: CustomStatCard(
                        title: 'Block',
                        value: controller.blockCount.value.toString(),
                      ), // Mocked as 0 for now
                    ),
                  ],
                ),
              ),

              const SpaceHeight(16),

              // Scan Ticket and View Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomActionCard(
                      label: 'Scan Ticket',
                      icon: Assets.icons.scan.image(height: 24),
                      onTap: () {
                        context.push(ScanTicketPage());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomActionCard(
                      label: 'View',
                      icon: Assets.icons.view.image(height: 24),
                      onTap: () {
                        context.push(ListVisitorPage());
                      },
                    ),
                  ),
                ],
              ),
              const SpaceHeight(25),
              Divider(height: 1, thickness: 0.3),
              const SpaceHeight(20),

              // New Parking Section
              Text(
                'New Visitor',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),

              // List of New Visitors
              // Showing top 5 recent visitors from controller
              Obx(() {
                if (controller.isLoading.value && controller.visitors.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final visitors = controller.visitors.take(5).toList();

                if (visitors.isEmpty) {
                  return const Text('No new visitors');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visitors.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return VisitorCard(
                      visitorName: visitor.name,
                      companyName: visitor.organisation,
                      destination: visitor.destination,
                      date: visitor.date,
                      timeRange: visitor.timeRange,
                      avatar: visitor.avatarUrl != null
                          ? Image.network(visitor.avatarUrl!)
                          : Assets.images.avaPerson1.image(height: 40),
                      idVisitor: visitor.visitorId,
                      invitationCode: visitor.invitationCode,
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
