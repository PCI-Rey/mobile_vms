import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import 'controllers/guest_home_controller.dart';
import 'widgets/access_pass_section.dart';
import 'widgets/access_pass_modal.dart';
import 'widgets/guest_header.dart';
import 'widgets/guest_menu_grid.dart';
import '../../core/helper/responsive_helper.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  final guestCtrl = Get.put(GuestHomeController());
  final langCtrl = LanguageController.to;
  final userCtrl = UserController.to;

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0D47A1);
  static const _bgPage = Color(0xFFF8FAFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Full background gradient
              Container(
                width: double.infinity,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // --- TOP FIXED HEADER ---
                    const GuestHeader(),

                    // --- SCROLLABLE BODY ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: rh(context, 32) +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              vSpace(context, 16),
                              const GuestMenuGrid(),
                              vSpace(context, 28),
                              AccessPassSection(
                                onTap: (item) =>
                                    AccessPassModal.show(context, item),
                              ),
                              vSpace(context, 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
