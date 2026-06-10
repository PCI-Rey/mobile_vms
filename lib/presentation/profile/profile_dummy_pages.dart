import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../auth/controller/user_controller.dart';

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
        title: const Text('Keamanan'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(rw(context, 20)),
              children: [
                _buildSectionHeader('Autentikasi'),
                _buildMenuItem(
                  icon: Icons.key_outlined,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Perbarui kata sandi Anda secara berkala',
                  onTap: () {
                    Get.snackbar('Info', 'Fitur Ubah Kata Sandi');
                  },
                ),
                vSpace(context, 12),
                _buildSwitchItem(
                  icon: Icons.security_outlined,
                  title: 'Autentikasi 2 Faktor (2FA)',
                  subtitle: 'Amankan akun Anda dengan verifikasi tambahan',
                  value: _twoFactor,
                  onChanged: (val) {
                    setState(() => _twoFactor = val);
                  },
                ),
                vSpace(context, 12),
                _buildSwitchItem(
                  icon: Icons.fingerprint_outlined,
                  title: 'Sidik Jari / Face ID',
                  subtitle: 'Masuk lebih cepat menggunakan biometrik',
                  value: _biometric,
                  onChanged: (val) {
                    setState(() => _biometric = val);
                  },
                ),
                vSpace(context, 24),
                _buildSectionHeader('Aktivitas Login'),
                _buildMenuItem(
                  icon: Icons.devices_outlined,
                  title: 'Perangkat Terhubung',
                  subtitle: 'Kelola perangkat yang sedang login',
                  onTap: () {},
                ),
                vSpace(context, 12),
                _buildMenuItem(
                  icon: Icons.history_outlined,
                  title: 'Riwayat Aktivitas',
                  subtitle: 'Lihat aktivitas masuk terakhir Anda',
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(rw(context, 20)),
            child: Button.filled(
              label: 'Kembali',
              onPressed: () => Get.back(),
            ),
          ),
        ],
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
        title: const Text('Pemberitahuan'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(rw(context, 20)),
              children: [
                _buildSectionHeader('Saluran Notifikasi'),
                _buildSwitchItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifikasi Push',
                  subtitle: 'Terima notifikasi instan di perangkat Anda',
                  value: _pushNotifications,
                  onChanged: (val) {
                    setState(() => _pushNotifications = val);
                  },
                ),
                vSpace(context, 12),
                _buildSwitchItem(
                  icon: Icons.email_outlined,
                  title: 'Notifikasi Email',
                  subtitle: 'Terima laporan dan pemberitahuan lewat email',
                  value: _emailNotifications,
                  onChanged: (val) {
                    setState(() => _emailNotifications = val);
                  },
                ),
                vSpace(context, 12),
                _buildSwitchItem(
                  icon: Icons.sms_outlined,
                  title: 'Pemberitahuan SMS',
                  subtitle: 'Kirim info darurat ke nomor seluler Anda',
                  value: _smsNotifications,
                  onChanged: (val) {
                    setState(() => _smsNotifications = val);
                  },
                ),
                vSpace(context, 24),
                _buildSectionHeader('Kategori Alert'),
                _buildSwitchItem(
                  icon: Icons.warning_amber_outlined,
                  title: 'Alarm & Peringatan',
                  subtitle: 'Peringatan ketika ada pelanggaran area/status',
                  value: _alarmAlerts,
                  onChanged: (val) {
                    setState(() => _alarmAlerts = val);
                  },
                ),
                vSpace(context, 12),
                _buildSwitchItem(
                  icon: Icons.check_circle_outline,
                  title: 'Pemberitahuan Approval',
                  subtitle: 'Notifikasi saat permintaan kunjungan disetujui',
                  value: _approvalNotifs,
                  onChanged: (val) {
                    setState(() => _approvalNotifs = val);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(rw(context, 20)),
            child: Button.filled(
              label: 'Kembali',
              onPressed: () => Get.back(),
            ),
          ),
        ],
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(rw(context, 20)),
              children: [
                _buildSectionHeader(context, 'Pertanyaan Populer (FAQ)'),
                _buildFaqItem(
                  context,
                  'Bagaimana cara mengundang tamu?',
                  'Buka halaman utama, pilih menu Send Invitation, pilih tab Invitation dan klik tombol tambah (+). Isi data tamu kemudian klik kirim.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Bagaimana cara merespon Alarm Alert?',
                  'Ketika ada alarm berbunyi, ketuk notifikasi alarm atau buka menu Alarm Alert, lalu Anda dapat menyetujui (Approve) atau menolak (Deny) alarm tersebut.',
                ),
                vSpace(context, 12),
                _buildFaqItem(
                  context,
                  'Mengapa barcode tamu tidak bisa dipindai?',
                  'Pastikan layar ponsel tamu cukup terang atau barcode belum melewati masa kedaluwarsa (expired).',
                ),
                vSpace(context, 24),
                _buildSectionHeader(context, 'Butuh Bantuan Lain?'),
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
                                Text('Hubungi Customer Service', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Aktif 24/7 untuk membantu Anda', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      vSpace(context, 16),
                      Button.filled(
                        label: 'Hubungi Support',
                        height: rh(context, 40),
                        onPressed: () {
                          Get.snackbar('Support', 'Menghubungi Tim Support...');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(rw(context, 20)),
            child: Button.filled(
              label: 'Kembali',
              onPressed: () => Get.back(),
            ),
          ),
        ],
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
      child: ExpansionTile(
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
        title: const Text('Barcode / QR Tamu'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(rw(context, 20)),
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
                          'ID PERANGKAT: EMP-${user?.id ?? '12345'}',
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
                                'Gunakan QR Code ini untuk akses masuk ke gerbang turnstile kantor.',
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
          Padding(
            padding: EdgeInsets.all(rw(context, 20)),
            child: Button.filled(
              label: 'Kembali',
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
