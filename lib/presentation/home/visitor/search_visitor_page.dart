import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../presentation/parking/scan_ticket_page.dart';
import '../../parking/widgets/custom_action_card.dart';
import 'controller/visitor_controller.dart';
import 'widgets/visitor_profile_widgets.dart';

class SearchVisitorPage extends StatefulWidget {
  const SearchVisitorPage({super.key});

  @override
  State<SearchVisitorPage> createState() => _SearchVisitorPageState();
}

class _SearchVisitorPageState extends State<SearchVisitorPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;
  late final VisitorController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<VisitorController>()) {
      controller = Get.find<VisitorController>();
    } else {
      controller = Get.put(VisitorController());
    }
    // Clean search text and reset filter on open
    _searchCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchVisitors('');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Visitor',
          style: TextStyle(
            fontSize: rfs(context, 20),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: rh(context, 1.0)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            CustomTextField(
              controller: _searchCtrl,
              label: 'Search',
              hintText: 'Type name, email, phone, organization, or NIK...',
              suffixIcon: const Icon(Icons.search),
              showLabel: false,
              onChanged: (val) {
                searchQuery.value = val;
                controller.searchVisitors(val);
              },
            ),
            vSpace(context, 16),

            // Scan Ticket Button
            SizedBox(
              width: double.infinity,
              child: CustomActionCard(
                label: 'Scan Ticket',
                icon: Assets.icons.scan.image(height: rh(context, 24)),
                onTap: () {
                  context.push(ScanTicketPage());
                },
              ),
            ),
            vSpace(context, 20),
            const Divider(height: 1, thickness: 0.3),
            vSpace(context, 10),

            // Live Results Section Header
            Obx(() {
              final query = searchQuery.value.trim();
              final label = query.isEmpty ? 'All Visitors' : 'Search Results';
              return Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 18.0),
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            vSpace(context, 16.0),

            // Results List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = controller.filteredVisitors;

                if (results.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada visitor yang cocok'),
                  );
                }

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (context, index) => vSpace(context, 12),
                  itemBuilder: (context, index) {
                    final visitor = results[index];
                    return VisitorProfileCard(
                      visitor: visitor,
                      index: index,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => VisitorProfileDetailSheet(visitor: visitor),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
