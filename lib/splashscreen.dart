import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/onboarding/language_selection_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../presentation/dashboard.dart';
import '../presentation/home/invitation/controller/invitation_controller.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 1200);
  static const Duration _minSplashDuration = Duration(seconds: 5);

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _handleSplashFlow();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _handleSplashFlow() async {
    final isAuthenticated = await _checkAuthentication();
    final delayFuture = Future.delayed(_minSplashDuration);

    if (isAuthenticated) {
      try {
        final controller = Get.isRegistered<InvitationController>()
            ? Get.find<InvitationController>()
            : Get.put(InvitationController());

        // Run prefetch in parallel with the 5-second splash timer.
        // It will never block navigation past 5 seconds.
        Future.wait([
          controller.fetchOngoingInvitations(isSilent: true),
          controller.fetchApprovalTickets(isSilent: true),
          controller.fetchDashboardShareLinks(),
        ]).catchError((e) {
          debugPrint('Splash prefetch error: $e');
          return <void>[];
        });
      } catch (e) {
        debugPrint('Splash prefetch error: $e');
      }
    }

    // Exactly 5 seconds total duration
    await delayFuture;

    if (!mounted) return;
    _navigateToNextScreen(isAuthenticated);
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
        : const LanguageSelectionPage();

    Get.off(
      () => nextScreen,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                animation: _controller,
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

                        SizedBox(height: sw * 0.12),

                        // Loading indicator — subtle dots
                        SizedBox(
                          width: sw * 0.08,
                          height: sw * 0.008,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
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
                              errorBuilder: (context, error, stackTrace) => Text(
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
