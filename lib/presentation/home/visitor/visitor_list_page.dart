import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'controller/visitor_controller.dart';

class ListVisitorPage extends StatefulWidget {
  const ListVisitorPage({super.key});

  @override
  State<ListVisitorPage> createState() => _ListVisitorPageState();
}

class _ListVisitorPageState extends State<ListVisitorPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  late final VisitorController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<VisitorController>()) {
      controller = Get.find<VisitorController>();
    } else {
      controller = Get.put(VisitorController());
    }
    // Load initial data
    controller.loadVisitors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('List Visitor'),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal scrollable filter row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            enableDrag: true,
                            isDismissible: true,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(rw(context, 16)),
                              ),
                            ),
                            builder: (context) => const FilterBottomSheet(),
                          );

                      if (result != null) {
                        setState(() {
                          startDate = result['startDate'];
                          endDate = result['endDate'];
                          selectedGedung = result['gedung'];
                        });

                        // Apply filter (Not fully implemented in controller yet, but structure is there)
                        // In real app, call a filter method
                        controller.loadVisitors(); // Reload for now
                      }
                    },
                    child: _buildFilterChip('Filter'),
                  ),

                  hSpace(context, 10),

                  if (selectedGedung != null)
                    _buildFilterValueChip(
                      selectedGedung!,
                      onClear: () {
                        setState(() => selectedGedung = null);
                        _applyFilter();
                      },
                    ),

                  hSpace(context, 10),

                  if (startDate != null || endDate != null)
                    _buildFilterValueChip(
                      _formatDateRange(startDate, endDate),
                      onClear: () {
                        setState(() {
                          startDate = null;
                          endDate = null;
                        });
                        _applyFilter();
                      },
                    ),

                  hSpace(context, 16),
                ],
              ),
            ),

            vSpace(context, 20),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage.value!),
                        vSpace(context, 16),
                        ElevatedButton(
                          onPressed: () {
                            controller.loadVisitors();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final visitors = controller.filteredVisitors;

                if (visitors.isEmpty) {
                  return const Center(child: Text('Tidak ada data visitor'));
                }

                return ListView.separated(
                  itemCount: visitors.length,
                  separatorBuilder: (_, _) => vSpace(context, 12),
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return Container(
                      padding: EdgeInsets.all(rw(context, 12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: rw(context, 40),
                                height: rw(context, 40),
                                child: ClipOval(
                                  child: visitor.avatarUrl != null
                                      ? Image.network(
                                          visitor.avatarUrl!,
                                          height: rw(context, 40),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Assets.images.avaPerson1
                                                      .image(height: rw(context, 40)),
                                        )
                                      : Assets.images.avaPerson1.image(
                                          height: rw(context, 40),
                                        ),
                                ),
                              ),
                              hSpace(context, 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      visitor.name,
                                      style: TextStyles.bodyLarge,
                                    ),
                                    Text(
                                      visitor.organisation,
                                      style: TextStyles.bodySmall,
                                    ),
                                    vSpace(context, 4),
                                    Text(
                                      visitor.destination,
                                      style: TextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    vSpace(context, 2),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    visitor.date,
                                    style: TextStyles.bodySmall,
                                  ),
                                  Text(
                                    visitor.timeRange,
                                    style: TextStyles.bodySmall,
                                  ),
                                  vSpace(context, 8),
                                  Text(
                                    visitor.invitationCode,
                                    style: TextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          vSpace(context, 10),
                          Center(
                            child: Text(
                              'ID : ${visitor.visitorId}',
                              style: TextStyles.subtitle1,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFilterChip(String label) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label),
          hSpace(context, 8),
          Icon(FontAwesomeIcons.chevronDown, size: rw(context, 14)),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: rfs(context, 12))),
          hSpace(context, 8),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: rw(context, 16)),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final format = DateFormat('dd/MM/yyyy');
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return 'Dari ${format.format(start)}';
    } else {
      return 'Sampai ${format.format(end!)}';
    }
  }

  void _applyFilter() {
    controller.loadVisitors();
  }
}
