import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import 'controller/visitor_controller.dart';
import 'widgets/visitor_profile_widgets.dart';

class ListVisitorPage extends StatefulWidget {
  const ListVisitorPage({super.key});

  @override
  State<ListVisitorPage> createState() => _ListVisitorPageState();
}

class _ListVisitorPageState extends State<ListVisitorPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final VisitorController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<VisitorController>()) {
      controller = Get.find<VisitorController>();
    } else {
      controller = Get.put(VisitorController());
    }
    // Load/reset visitors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVisitors();
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
        title: const Text('List Visitor'),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            CustomTextField(
              controller: _searchCtrl,
              label: 'Search',
              hintText: 'Search by name, email, phone, organization...',
              suffixIcon: const Icon(Icons.search),
              showLabel: false,
              onChanged: (val) {
                controller.searchVisitors(val);
              },
            ),
            vSpace(context, 20),

            // Visitor profiles list
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
                  separatorBuilder: (context, index) => vSpace(context, 12),
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
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
