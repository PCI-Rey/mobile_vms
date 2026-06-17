// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../auth/controller/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================================
// SECURITY PAGE
// ============================================================================
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _twoFactor = false;
  bool _biometric = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Security'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rw(context, 20),
            bottom: rh(context, 40),
          ),
        children: [
          _buildSectionHeader('Authentication'),
          _buildMenuItem(
            icon: Icons.key_outlined,
            title: 'Change Password',
            subtitle: 'Update your password regularly',
            onTap: () {
              Get.snackbar('Info', 'Change Password Feature');
            },
          ),
          vSpace(context, 12),
          _buildSwitchItem(
            icon: Icons.security_outlined,
            title: '2-Factor Authentication (2FA)',
            subtitle: 'Secure your account with additional verification',
            value: _twoFactor,
            onChanged: (val) {
              setState(() => _twoFactor = val);
            },
          ),
          vSpace(context, 12),
          _buildSwitchItem(
            icon: Icons.fingerprint_outlined,
            title: 'Fingerprint / Face ID',
            subtitle: 'Sign in faster using biometrics',
            value: _biometric,
            onChanged: (val) {
              setState(() => _biometric = val);
            },
          ),
          vSpace(context, 24),
          _buildSectionHeader('Login Activity'),
          _buildMenuItem(
            icon: Icons.devices_outlined,
            title: 'Connected Devices',
            subtitle: 'Manage devices currently logged in',
            onTap: () {},
          ),
          vSpace(context, 12),
          _buildMenuItem(
            icon: Icons.history_outlined,
            title: 'Activity History',
            subtitle: 'View your recent login activity',
            onTap: () {},
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12), left: rw(context, 4)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary500),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary500),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary500,
        ),
      ),
    );
  }
}

// ============================================================================
// PEMBERITAHUAN PAGE
// ============================================================================
class PemberitahuanPage extends StatefulWidget {
  const PemberitahuanPage({super.key});

  @override
  State<PemberitahuanPage> createState() => _PemberitahuanPageState();
}

class _PemberitahuanPageState extends State<PemberitahuanPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _alarmAlerts = true;
  bool _approvalNotifs = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rw(context, 20),
            bottom: rh(context, 40),
          ),
        children: [
          _buildSectionHeader('Notification Channels'),
          _buildSwitchItem(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive instant notifications on your device',
            value: _pushNotifications,
            onChanged: (val) {
              setState(() => _pushNotifications = val);
            },
          ),
          vSpace(context, 12),
          _buildSwitchItem(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive reports and alerts via email',
            value: _emailNotifications,
            onChanged: (val) {
              setState(() => _emailNotifications = val);
            },
          ),
          vSpace(context, 12),
          _buildSwitchItem(
            icon: Icons.sms_outlined,
            title: 'SMS Notifications',
            subtitle: 'Send urgent info to your mobile number',
            value: _smsNotifications,
            onChanged: (val) {
              setState(() => _smsNotifications = val);
            },
          ),
          vSpace(context, 24),
          _buildSectionHeader('Alert Categories'),
          _buildSwitchItem(
            icon: Icons.warning_amber_outlined,
            title: 'Alarms & Warnings',
            subtitle: 'Alerts when there is an area/status violation',
            value: _alarmAlerts,
            onChanged: (val) {
              setState(() => _alarmAlerts = val);
            },
          ),
          vSpace(context, 12),
          _buildSwitchItem(
            icon: Icons.check_circle_outline,
            title: 'Approval Notifications',
            subtitle: 'Notified when a visit request is approved',
            value: _approvalNotifs,
            onChanged: (val) {
              setState(() => _approvalNotifs = val);
            },
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12), left: rw(context, 4)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary500),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary500,
        ),
      ),
    );
  }
}

// ============================================================================
// HELP CENTER PAGE
// ============================================================================
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Help Center'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Obx(() {
          final user = UserController.to.user.value;
          final bool isEmployee =
              (user?.roleAccess?.toLowerCase() == 'employee' ||
                  user?.roleAccess?.toLowerCase() == 'admin') &&
              (user?.invitationCode == null || user!.invitationCode!.isEmpty) &&
              (user?.visitorCode == null || user!.visitorCode!.isEmpty);

          return ListView(
            padding: EdgeInsets.only(
              left: rw(context, 20),
              right: rw(context, 20),
              top: rw(context, 20),
              bottom: rh(context, 40),
            ),
            children: [
              _buildSectionHeader(context, 'Popular Questions (FAQ)'),
              if (isEmployee) ...[
                _buildFaqItem(
                  context,
                  'How do I invite a guest?',
                  'Open the home tab, select the \'Invitation\' menu, and tap the add (+) button. Fill in the guest details and tap send.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I respond to an Alarm Alert?',
                  'When an alarm sounds, tap the alarm notification or open the Alarm Alert menu, then you can Approve or Deny the alarm.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'What is the Share Link feature for?',
                  'The Share Link menu lets you generate a registration link. You can send this link to your guests so they can fill out their visitor details in advance.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I approve or reject a visit request?',
                  'Tap the \'Approval\' menu on your dashboard. You will see a list of pending requests; select a request and tap \'Approve\' or \'Reject\'.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'What should I do during an Evacuation Alert?',
                  'Open the Evacuate menu on your dashboard. Follow the instructions to proceed to the designated assembly point and register your status to confirm you are safe.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I scan a parking ticket?',
                  'Go to the Parking menu on the dashboard, select Scan Ticket, and use your device camera to scan the QR/barcode printed on your physical parking slip.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I manage my notifications?',
                  'Go to your Profile tab, select Notification, and toggle your preferences for push notifications, email reports, SMS alerts, or category filters.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Can I check who is logged into my account?',
                  'Yes. In the Profile tab, tap Security, then select Connected Devices to review all active sessions or change your password regularly.',
                ),
              ] else ...[
                _buildFaqItem(
                  context,
                  'How do I complete my visit pre-registration?',
                  'Open the invitation link sent by your host, or enter your invitation code on the app\'s entry screen. Fill in your personal information, upload any required files, and submit the form.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I enter the office building?',
                  'Go to your Profile tab, tap Barcode, and present the generated QR Code to the scanner at the turnstile gate or lobby reception.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Why can\'t my guest barcode be scanned?',
                  'Ensure your screen brightness is set to high, the barcode is fully visible, and the scheduled visit time and date are currently valid.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I register my vehicle?',
                  'When filling out your registration form, select \'Yes\' for the vehicle question and enter your license plate number and vehicle details.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I check my active visit details?',
                  'Your active Guest Pass is displayed on the main home screen of the app, containing your host\'s name, visit location, and scheduled duration.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Can I register multiple people for a group visit?',
                  'Yes. When registering, you can add multiple visitors or choose the option to register colleagues under the same invitation code.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'How do I manage my notifications?',
                  'Go to your Profile tab, select Notification, and toggle your preferences for push notifications, email reports, or SMS alerts.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Can I check who is logged into my account?',
                  'Yes. In the Profile tab, tap Security, then select Connected Devices to review all active sessions.',
                ),
              ],
              vSpace(context, 24),
              _buildSectionHeader(context, 'Need More Help?'),
              Container(
                padding: EdgeInsets.all(rw(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.headset_mic_outlined, color: AppColors.primary500, size: rw(context, 28)),
                        hSpace(context, 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Contact Customer Service', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Available 24/7 to help you', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    vSpace(context, 16),
                    Button.filled(
                      label: 'Contact Support',
                      height: rh(context, 40),
                      onPressed: () async {
                        final Uri url = Uri.parse('https://bio-experience.com/');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          Get.snackbar('Error', 'Could not launch support page.');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12), left: rw(context, 4)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          textColor: AppColors.primary500,
          iconColor: AppColors.primary500,
          collapsedIconColor: Colors.grey.shade600,
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(rw(context, 16), 0, rw(context, 16), rh(context, 16)),
              child: Text(
                answer,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BARCODE PAGE
// ============================================================================
class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserController.to.user.value;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Barcode / QR Code'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rw(context, 20),
            bottom: rh(context, 40),
          ),
        child: Column(
          children: [
            vSpace(context, 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rw(context, 24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    user?.fullname ?? 'Employee Pass',
                    style: TextStyle(
                      fontSize: rfs(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  vSpace(context, 4),
                  Text(
                    user?.roleAccess?.toUpperCase() ?? 'EMPLOYEE',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: AppColors.primary500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  vSpace(context, 24),
                  // QR Code Simulation
                  Container(
                    width: rw(context, 200),
                    height: rw(context, 200),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(rw(context, 16)),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: Icon(
                      Icons.qr_code_2_outlined,
                      size: rw(context, 160),
                      color: Colors.black87,
                    ),
                  ),
                  vSpace(context, 24),
                  Text(
                    'DEVICE ID: EMP-${user?.id ?? '12345'}',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  vSpace(context, 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  vSpace(context, 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: rw(context, 16), color: Colors.grey),
                      hSpace(context, 8),
                      const Expanded(
                        child: Text(
                          'Use this QR Code to access the office turnstile gate.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
