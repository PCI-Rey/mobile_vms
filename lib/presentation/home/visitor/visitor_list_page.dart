import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
        padding: const EdgeInsets.all(16),
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
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
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

                  const SizedBox(width: 10),

                  if (selectedGedung != null)
                    _buildFilterValueChip(
                      selectedGedung!,
                      onClear: () {
                        setState(() => selectedGedung = null);
                        _applyFilter();
                      },
                    ),

                  const SizedBox(width: 10),

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

                  const SizedBox(width: 16),
                ],
              ),
            ),

            const SpaceHeight(20),

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
                        const SizedBox(height: 16),
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
                  separatorBuilder: (_, __) => const SpaceHeight(12),
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: ClipOval(
                                  child: visitor.avatarUrl != null
                                      ? Image.network(
                                          visitor.avatarUrl!,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Assets.images.avaPerson1
                                                      .image(height: 40),
                                        )
                                      : Assets.images.avaPerson1.image(
                                          height: 40,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),

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
                                    const SpaceHeight(4),
                                    Text(
                                      visitor.destination,
                                      style: TextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SpaceHeight(2),
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
                                  const SpaceHeight(8),
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

                          const SpaceHeight(10),
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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          const Icon(FontAwesomeIcons.chevronDown, size: 14),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16),
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
