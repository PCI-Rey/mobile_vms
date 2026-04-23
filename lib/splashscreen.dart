import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import '../presentation/onboarding/language_selection_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../presentation/dashboard.dart';
import 'core/core.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  static const Duration _animationDuration = Duration(seconds: 3);
  static const Duration _minSplashDuration = Duration(seconds: 5);

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

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  Future<void> _handleSplashFlow() async {
    final authFuture = _checkAuthentication();
    final delayFuture = Future.delayed(_minSplashDuration);

    final results = await Future.wait([authFuture, delayFuture]);
    final isAuthenticated = results[0] as bool;

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

    // Always use pushReplacement to remove splashscreen from stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary500,
      body: Center(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) => Opacity(
            opacity: _opacityAnimation.value,
            child: Assets.images.iconApp.image(
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}