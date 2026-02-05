import 'package:flutter/material.dart';
import '../../core/components/components.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/profile/profile_detail_page.dart';

import '../../core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F3FB),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            color: const Color(0xFFE3F3FB),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                CustomCircleImage(
                  image: Assets.images.avaPerson1.image(),
                  size: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tommy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'tommy@mail.com',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffD6F0FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Operator',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff1976D2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TileMenu(
                  icon: const Icon(Icons.person, color: Colors.white, size: 25),
                  label: 'Akun',
                  onTap: () {
                    context.push(DetailProfilePage());
                  },
                ),
                const SizedBox(height: 12),
                TileMenu(
                  icon: const Icon(Icons.lock, color: Colors.white, size: 25),
                  label: 'Security',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const Spacer(),

          // Logout button
          Container(
            width: double.infinity,
            height: 41,
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                final authDatasource = AuthDatasource();
                final result = await authDatasource.logout();
                if (result && context.mounted) {
                  context.push(LoginPage());
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Gagal logout')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.error500, width: 1),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Keluar',
                style: TextStyle(color: AppColors.error500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
