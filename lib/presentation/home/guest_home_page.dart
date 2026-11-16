import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import 'controllers/guest_home_controller.dart';
import 'widgets/access_pass_modal.dart';
import 'widgets/guest_header.dart';
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
                bottom: true,
                child: Column(
                  children: [
                    // --- TOP FIXED HEADER ---
                    const GuestHeader(),

                    // --- DIRECT VISITOR CARD BODY ---
                    Expanded(
                      child: RefreshIndicator(
                        color: _blue,
                        backgroundColor: Colors.white,
                        onRefresh: () async {
                          await guestCtrl.fetchAccessPass();
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              rw(context, 16),
                              rh(context, 8),
                              rw(context, 16),
                              rh(context, 16),
                            ),
                            child: Obx(() {
                              langCtrl.selectedLang.value;

                              if (guestCtrl.isLoading.value) {
                                return _buildLoadingPlaceholder(context);
                              }

                              if (guestCtrl.accessPasses.isEmpty) {
                                return _buildEmptyState(context);
                              }

                              final int total = guestCtrl.accessPasses.length;
                              final int currentIndex =
                                  guestCtrl.selectedPassIndex.value;
                              final int safeIndex =
                                  (currentIndex >= 0 && currentIndex < total)
                                      ? currentIndex
                                      : 0;
                              final item = guestCtrl.accessPasses[safeIndex];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Multiple passes indicator/switcher
                                  if (total > 1) ...[
                                    _buildPassSwitcher(
                                      context,
                                      safeIndex,
                                      total,
                                    ),
                                    vSpace(context, 8),
                                  ],

                                  // ── 1. Check In & Check Out Row ──
                                  CheckStatusRow(item: item),
                                  vSpace(context, 10),

                                  // ── 2. Full Web-Style Visitor Code Card ──
                                  WebVisitorCodeCard(item: item),
                                  vSpace(context, 8),
                                ],
                              );
                            }),
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

  Widget _buildPassSwitcher(
    BuildContext context,
    int currentIndex,
    int total,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 14),
        vertical: rh(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: currentIndex > 0
                ? () => guestCtrl.selectPass(currentIndex - 1)
                : null,
            child: Icon(
              Icons.chevron_left_rounded,
              color: currentIndex > 0 ? Colors.white : Colors.white38,
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 10),
          Text(
            'Pass ${currentIndex + 1} / $total',
            style: TextStyle(
              color: Colors.white,
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w700,
            ),
          ),
          hSpace(context, 10),
          GestureDetector(
            onTap: currentIndex < total - 1
                ? () => guestCtrl.selectPass(currentIndex + 1)
                : null,
            child: Icon(
              Icons.chevron_right_rounded,
              color: currentIndex < total - 1 ? Colors.white : Colors.white38,
              size: rw(context, 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(context, 28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: rw(context, 16),
            offset: Offset(0, rh(context, 4)),
          ),
        ],
      ),
      child: Column(
        children: [
          vSpace(context, 24),
          const CircularProgressIndicator(color: _blue),
          vSpace(context, 16),
          Text(
            'Memuat Visitor Code...',
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          vSpace(context, 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 24),
        vertical: rh(context, 40),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: rw(context, 16),
            offset: Offset(0, rh(context, 4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(rw(context, 18)),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: rw(context, 48),
              color: _blue,
            ),
          ),
          vSpace(context, 16),
          Text(
            'Belum Ada Access Pass',
            style: TextStyle(
              fontSize: rfs(context, 16),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          vSpace(context, 6),
          Text(
            'Access pass Anda akan muncul di sini setelah terdaftar atau disetujui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 12),
              color: const Color(0xFF64748B),
            ),
          ),
          vSpace(context, 20),
          SizedBox(
            height: rh(context, 40),
            child: ElevatedButton.icon(
              onPressed: () => guestCtrl.fetchAccessPass(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
