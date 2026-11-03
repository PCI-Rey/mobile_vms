import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/helper/responsive_helper.dart';
// import '../presentation/onboarding/language_selection_page.dart';
import '../presentation/auth/login_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../presentation/dashboard.dart';
import '../presentation/home/invitation/controller/invitation_controller.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 1200);

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);

  String _statusMessage = 'Starting application...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _handleSplashFlow();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _logoController.forward();
  }

  Future<void> _updateProgress(double target, String message) async {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
    await _progressController.animateTo(
      target.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleSplashFlow() async {
    // 0% -> 5%
    await _updateProgress(0.05, 'Checking user session...');
    await Future.delayed(const Duration(milliseconds: 300));

    final isAuthenticated = await _checkAuthentication();

    if (!isAuthenticated) {
      // Flow user belum login: animasikan 0% -> 100% lalu buka LoginPage
      await _updateProgress(0.40, 'Preparing login...');
      await Future.delayed(const Duration(milliseconds: 400));
      await _updateProgress(0.75, 'Initializing system...');
      await Future.delayed(const Duration(milliseconds: 300));
      await _updateProgress(1.0, 'Ready');
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _navigateToNextScreen(false);
      return;
    }

    // Flow user sudah login: Fetch data real dari backend (0 - 100%)
    try {
      final controller = Get.isRegistered<InvitationController>()
          ? Get.find<InvitationController>()
          : Get.put(InvitationController(), permanent: true);

      // Task 1: Daftar Transaksi & Invitation (target: 25%)
      await _updateProgress(0.12, 'Loading transactions & invitations...');
      await controller
          .fetchOngoingInvitations(isSilent: true)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout fetchOngoingInvitations');
      }).catchError((e) {
        debugPrint('Splash ongoingInvitations error: $e');
      });
      await _updateProgress(0.25, 'Transactions & invitations ready');
      await Future.delayed(const Duration(milliseconds: 100));

      // Task 2: Detail Data Tamu / Sub-Visitors (target: 45%)
      await _updateProgress(0.32, 'Loading visitor details...');
      await controller
          .prefetchRecentTransactionVisitors(limit: 15)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout prefetchRecentTransactionVisitors');
      }).catchError((e) {
        debugPrint('Splash prefetchRecentTransactionVisitors error: $e');
      });
      await _updateProgress(0.45, 'Visitor details ready');
      await Future.delayed(const Duration(milliseconds: 100));

      // Task 3: Tiket Approval (target: 60%)
      await _updateProgress(0.52, 'Loading approval tickets...');
      await controller
          .fetchApprovalTickets(isSilent: true)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout fetchApprovalTickets');
      }).catchError((e) {
        debugPrint('Splash approvalTickets error: $e');
      });
      await _updateProgress(0.60, 'Approval tickets ready');
      await Future.delayed(const Duration(milliseconds: 100));

      // Task 4: Share Link (target: 74%)
      await _updateProgress(0.66, 'Loading share links...');
      await controller
          .fetchDashboardShareLinks()
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout fetchDashboardShareLinks');
      }).catchError((e) {
        debugPrint('Splash shareLinks error: $e');
      });
      await _updateProgress(0.74, 'Share links ready');
      await Future.delayed(const Duration(milliseconds: 100));

      // Task 5: Aktivitas Hari Ini (target: 86%)
      await _updateProgress(0.80, 'Loading today\'s activities...');
      await controller
          .fetchTodayActivities(isSilent: true)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout fetchTodayActivities');
      }).catchError((e) {
        debugPrint('Splash todayActivities error: $e');
      });
      await _updateProgress(0.86, 'Activities ready');
      await Future.delayed(const Duration(milliseconds: 100));

      // Task 6: Data Master (Gedung, Host, Visitor Type, Drop Points) (target: 100%)
      await _updateProgress(0.92, 'Loading master data...');
      await controller
          .fetchMasterData()
          .timeout(const Duration(seconds: 6), onTimeout: () {
        debugPrint('Timeout fetchMasterData');
      }).catchError((e) {
        debugPrint('Splash masterData error: $e');
      });
      await _updateProgress(1.0, 'All data ready!');
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint('Splash loading error: $e');
      await _updateProgress(1.0, 'Ready');
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!mounted) return;
    _navigateToNextScreen(true);
  }

  Future<bool> _checkAuthentication() async {
    try {
      return await AuthDatasource().isAuthDataExist();
    } catch (e) {
      debugPrint('Authentication check failed: $e');
      return false;
    }
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    final nextScreen = isAuthenticated
        ? const Dashboard()
        // : const LanguageSelectionPage();
        : const LoginPage();

    Get.off(
      () => nextScreen,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient background — same brand gradient as buttons/cards
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_blue, _blueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative circles (depth effect) ──────────────
            Positioned(
              top: -sw * 0.3,
              right: -sw * 0.2,
              child: Container(
                width: sw * 0.8,
                height: sw * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -sw * 0.25,
              left: -sw * 0.15,
              child: Container(
                width: sw * 0.7,
                height: sw * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // ── Center content ──────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo circle
                        SizedBox(
                          width: sw * 0.28,
                          height: sw * 0.28,
                          child: Image.asset(
                            'assets/images/VMS.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: sw * 0.06),

                        // App name
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'VISITOR MANAGEMENT SYSTEM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.054,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: sw * 0.02),

                        // Tagline
                        Text(
                          'Smart Visitor Experience',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.70),
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: rh(context, 90)),

                        // ── Real Progress Bar (0% - 100%) ────────────────
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            final percent =
                                (_progressController.value * 100).toInt();
                            final progress =
                                _progressController.value.clamp(0.0, 1.0);

                            return SizedBox(
                              width: sw * 0.72,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Progress Bar track & fill
                                  Container(
                                    height: rh(context, 7),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(
                                        rw(context, 10),
                                      ),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          progress > 0.01 ? progress : 0.01,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            rw(context, 10),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 6,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  vSpace(context, 10),

                                  // Status label & percentage text
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _statusMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                            fontSize: rfs(context, 12),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      hSpace(context, 8),
                                      Text(
                                        '$percent%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: rfs(context, 13),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Version / copyright at bottom ──────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + sw * 0.04,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (_, _) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '© 2026 VMS. All rights reserved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: sw * 0.028,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Powered by',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: sw * 0.028,
                            ),
                          ),
                          const SizedBox(width: 0),
                          Transform.translate(
                            offset: const Offset(-3, 0),
                            child: Image.asset(
                              'assets/images/BioExperienceWhite.png',
                              height: sw * 0.05,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Text(
                                'Bio Experience',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: sw * 0.028,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
