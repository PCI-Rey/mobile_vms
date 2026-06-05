import 'package:flutter/material.dart';
import '../../../../presentation/home/visitor/search_visitor_page.dart';
import '../../../../presentation/home/visitor/visitor_list_page.dart';
import '../../../../presentation/parking/scan_ticket_page.dart';
import 'package:get/get.dart';

import '../../../../core/helper/responsive_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Visitor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(rw(context, 16.0)),
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
                    suffixIcon: const Icon(Icons.search),
                    showLabel: false,
                    readOnly: true,
                  ),
                ),
              ),

              vSpace(context, 20),
              const Divider(height: 1, thickness: 0.3),
              vSpace(context, 20),

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
                    hSpace(context, 16),
                    Expanded(
                      child: CustomStatCard(
                        title: 'Check in',
                        value: controller.checkInCount.value.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              vSpace(context, 16.0),
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
                    hSpace(context, 16),
                    Expanded(
                      child: CustomStatCard(
                        title: 'Block',
                        value: controller.blockCount.value.toString(),
                      ), // Mocked as 0 for now
                    ),
                  ],
                ),
              ),

              vSpace(context, 16),

              // Scan Ticket and View Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomActionCard(
                      label: 'Scan Ticket',
                      icon: Assets.icons.scan.image(height: rh(context, 24)),
                      onTap: () {
                        context.push(ScanTicketPage());
                      },
                    ),
                  ),
                  hSpace(context, 16),
                  Expanded(
                    child: CustomActionCard(
                      label: 'View',
                      icon: Assets.icons.view.image(height: rh(context, 24)),
                      onTap: () {
                        context.push(ListVisitorPage());
                      },
                    ),
                  ),
                ],
              ),
              vSpace(context, 25),
              const Divider(height: 1, thickness: 0.3),
              vSpace(context, 20),

              // New Parking Section
              Text(
                'New Visitor',
                style: TextStyle(fontSize: rfs(context, 18.0), fontWeight: FontWeight.bold),
              ),
              vSpace(context, 8.0),

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
                  separatorBuilder: (context, index) => vSpace(context, 12),
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
                          : Assets.images.avaPerson1.image(height: rw(context, 40)),
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
