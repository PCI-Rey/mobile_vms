import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/forgot_password/input_email_page.dart';
import '../../presentation/auth/verification_code_page.dart';
import 'controller/login_controller.dart';
import '../../data/datasources/api_service.dart';
import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';
import 'widgets/captcha_box_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1976D2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.34;
          final bottomInset = MediaQuery.of(context).viewPadding.bottom;
          // Shifted slightly down right towards the navigation bar boundary
          final safeBottomPadding =
              bottomInset > 0 ? (bottomInset - 6.0) : 0.0;

          return Stack(
            children: [
              // 1. Blue Header Background (Gradient)
              Container(
                width: double.infinity,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. Decorative Circles (For depth)
              Positioned(
                top: -sw * 0.2,
                right: -sw * 0.1,
                child: Container(
                  width: sw * 0.5,
                  height: sw * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.55,
                left: -sw * 0.15,
                child: Container(
                  width: sw * 0.4,
                  height: sw * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 3. Hero Content
              Container(
                width: double.infinity,
                height: heroHeight,
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Circle (Tap 3x for Base URL settings)
                    GestureDetector(
                      onTap: _handleLogoTap,
                      child: SizedBox(
                        width: sw * 0.21,
                        height: sw * 0.21,
                        child: Image.asset(
                          'assets/images/VMS.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.02),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VISITOR MANAGEMENT SYSTEM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rfs(context, 21),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'login_hero_tagline'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: rfs(context, 12.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. White Content Card (Compact, padat & rapat)
              Positioned(
                top: heroHeight * 0.96, // Shifted slightly down
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: sw * 0.06,
                      right: sw * 0.06,
                      top: sw * 0.048,
                      bottom: safeBottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'welcome_back'.tr,
                          style: TextStyle(
                            fontSize: rfs(context, 20),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'login_subtitle'.tr,
                          style: TextStyle(
                            fontSize: rfs(context, 12.5),
                            color: const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: sw * 0.035),

                        // Form Fields
                        Obx(
                          () => _buildTextField(
                            controller: controller.usernameController,
                            label: 'username'.tr,
                            hintText: 'login_username_hint'.tr,
                            prefixIcon: Icons.person_outline,
                            errorText: controller.usernameError.value,
                            sw: sw,
                            context: context,
                          ),
                        ),
                        SizedBox(height: sw * 0.022),
                        Obx(
                          () => _buildTextField(
                            controller: controller.passwordController,
                            label: 'password'.tr,
                            hintText: 'login_password_hint'.tr,
                            prefixIcon: Icons.lock_outline,
                            isObscure: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  controller.togglePasswordVisibility(),
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: sw * 0.048,
                              ),
                            ),
                            errorText: controller.passwordError.value,
                            sw: sw,
                            context: context,
                          ),
                        ),

                        SizedBox(height: sw * 0.015),
                        GestureDetector(
                          onTap: () => context.push(const InputEmailPage()),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'forgot_password'.tr,
                              style: TextStyle(
                                color: const Color(0xFF1976D2),
                                fontSize: rfs(context, 12.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: sw * 0.022),

                        // Captcha Section
                        Obx(
                          () => CaptchaBoxWidget(
                            captchaCode: controller.captchaCode.value,
                            captchaSvg: controller.captchaSvg.value,
                            isRefreshing: controller.isRefreshingCaptcha.value,
                            onRefresh: () => controller.refreshCaptcha(),
                            controller: controller.captchaController,
                            errorText: controller.captchaError.value,
                            sw: sw,
                          ),
                        ),

                        // Spacing padat dan presisi menuju tombol Login
                        SizedBox(height: sw * 0.035),

                        // Login Button
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1976D2),
                              ),
                            );
                          }
                          return _buildPrimaryButton(
                            onPressed: () => controller.login(),
                            label: 'login'.tr,
                            sw: sw,
                            context: context,
                          );
                        }),

                        SizedBox(height: sw * 0.022),

                        // Guest Button
                        GestureDetector(
                          onTap: () =>
                              context.push(const VerificationCodePage()),
                          child: Container(
                            width: double.infinity,
                            height: sw * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.03),
                              border: Border.all(
                                color: const Color(
                                  0xFF1976D2,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'login_as_guest'.tr,
                                style: TextStyle(
                                  color: const Color(0xFF1976D2),
                                  fontSize: rfs(context, 14.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required double sw,
    required BuildContext context,
    bool isObscure = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: sw * 0.01, bottom: sw * 0.012),
          child: Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 13.5),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(
            fontSize: rfs(context, 13.5),
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: rfs(context, 13.5),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF1976D2),
              size: sw * 0.048,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF4F7FB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.038,
              vertical: sw * 0.032,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 1.5,
              ),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required double sw,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: sw * 0.125,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.03),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // --- Secret Developer / Base URL Setting Trigger (Tap logo 3x) ---
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  void _handleLogoTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds > 1500) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
    }
    _lastTapTime = now;

    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      _showPasswordDialog();
    }
  }

  void _showPasswordDialog() {
    final pinController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Server Configuration Access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter password to access Base URL configuration:',
                    style: TextStyle(fontSize: 13.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••',
                      hintStyle: const TextStyle(letterSpacing: 8),
                      counterText: '',
                      errorText: errorMessage,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim() == '0000') {
                        Navigator.pop(dialogCtx);
                        _showBaseUrlDialog();
                      } else {
                        setDialogState(() {
                          errorMessage = 'Incorrect password! (Hint: 0000)';
                        });
                      }
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (pinController.text.trim() == '0000') {
                      Navigator.pop(dialogCtx);
                      _showBaseUrlDialog();
                    } else {
                      setDialogState(() {
                        errorMessage = 'Incorrect password! (Hint: 0000)';
                      });
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBaseUrlDialog() {
    final currentBaseUrl = ApiService().baseUrl;
    final urlController = TextEditingController(text: currentBaseUrl);

    bool isTesting = false;
    bool? testSuccess;
    String testMessage = '';
    String lastTestedUrl = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dns_rounded,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Base URL Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Base URL badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFF1976D2),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Active: $currentBaseUrl',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0D47A1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'New Base URL:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              urlController.clear();
                              setDialogState(() {
                                testSuccess = null;
                                testMessage = '';
                              });
                            },
                          ),
                        ),
                        onChanged: (val) {
                          if (testSuccess != null) {
                            setDialogState(() {
                              testSuccess = null;
                              testMessage = '';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Reset Default & Test Connection Buttons in ONE single row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Reset to Default',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              onPressed: () {
                                urlController.text = ApiService.defaultBaseUrl;
                                setDialogState(() {
                                  testSuccess = null;
                                  testMessage = '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isTesting
                                  ? null
                                  : () async {
                                      final target = urlController.text.trim();
                                      if (target.isEmpty) {
                                        setDialogState(() {
                                          testSuccess = false;
                                          testMessage = 'URL cannot be empty!';
                                        });
                                        return;
                                      }

                                      setDialogState(() {
                                        isTesting = true;
                                        testMessage = '';
                                      });

                                      final res = await ApiService.testConnection(target);

                                      setDialogState(() {
                                        isTesting = false;
                                        testSuccess = res.isSuccess;
                                        testMessage = res.message;
                                        lastTestedUrl = target;
                                      });
                                    },
                              icon: isTesting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.bolt_rounded, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isTesting ? 'Testing...' : 'Test Connection',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Connection Test Result Banner
                      if (isTesting) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pinging and testing server connection...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (testSuccess == true) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  testMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (testSuccess == false) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  testMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please run "Test Connection" to verify the server is reachable before applying.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final target = urlController.text.trim();
                    if (target.isEmpty) {
                      setDialogState(() {
                        testSuccess = false;
                        testMessage = 'URL cannot be empty!';
                      });
                      return;
                    }

                    // Must verify connection before apply
                    if (testSuccess != true || lastTestedUrl != target) {
                      setDialogState(() {
                        isTesting = true;
                        testMessage = '';
                      });

                      final testRes = await ApiService.testConnection(target);

                      setDialogState(() {
                        isTesting = false;
                        testSuccess = testRes.isSuccess;
                        testMessage = testRes.message;
                        lastTestedUrl = target;
                      });

                      if (!testRes.isSuccess) {
                        Get.snackbar(
                          'Warning',
                          'Server is unreachable. Please verify the URL and ensure the server is active before applying!',
                          backgroundColor: Colors.red.shade700,
                          colorText: Colors.white,
                          icon: const Icon(Icons.error_outline, color: Colors.white),
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 4),
                        );
                        return;
                      }
                    }

                    // Save and apply new base URL
                    await ApiService.saveBaseUrl(target);
                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                    }

                    Get.snackbar(
                      'Success',
                      'Base URL applied successfully:\n${ApiService().baseUrl}',
                      backgroundColor: Colors.green.shade700,
                      colorText: Colors.white,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
