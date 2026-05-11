import 'package:flutter/material.dart';
import 'home/guest_home_page.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
import 'parking/as_operator/parking_page.dart';
import 'profile/profile_page.dart';
import '../core/core.dart';
// import 'widgets/is_block_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../presentation/auth/login_page.dart';
// import '../presentation/auth/controller/language_controller.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  String? _role;
  late List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetup();
  }

  Future<void> _loadRoleAndSetup() async {
    final user = await AuthDatasource().getAuthData();

    if (!mounted) return;

    if (user == null) {
      context.pushReplacement(const LoginPage());
      return;
    }

    final role = (user.roleAccess ?? 'guest').toLowerCase();
    if (!mounted) return;

    setState(() {
      _role = role;
    });

    _setupByRole(role);
  }

  void _setupByRole(String role) {
    List<Widget> widgets = [
      const HomePage(),
      ParkingPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    if (role == 'guest' || role == 'visitor') {
      widgets = [const GuestHomePage(), const ProfilePage()];
    } else if (role == 'operator') {
      widgets = [
        const HomePage(),
        ParkingPage(),
        const HistoryPage(),
        const ProfilePage(),
      ];
    }

    setState(() {
      _widgets = widgets;
      if (_selectedIndex >= _widgets.length) _selectedIndex = 0;
    });
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    final items = [
      BottomNavigationBarItem(
        icon: Assets.icons.home.image(height: 24, width: 24),
        activeIcon: Assets.icons.homeSelected.image(height: 24, width: 24),
        label: 'home'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.parking.image(height: 24, width: 24),
        activeIcon: Assets.icons.parkingSelected.image(height: 24, width: 24),
        label: 'parking'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.history.image(height: 24, width: 24),
        activeIcon: Assets.icons.historySelected.image(height: 24, width: 24),
        label: 'history'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.profile.image(height: 24, width: 24),
        activeIcon: Assets.icons.profileSelected.image(height: 24, width: 24),
        label: 'profile'.tr,
      ),
    ];

    if (role == 'guest' || role == 'visitor') {
      return [items[0], items[3]];
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isGuest = _role == 'guest' || _role == 'visitor';

    return Scaffold(
      backgroundColor: isGuest ? const Color(0xFF1976D2) : Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _widgets),
      bottomNavigationBar: isGuest
          ? null
          : Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.white,
                  highlightColor: Colors.white,
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (value) => setState(() => _selectedIndex = value),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  items: _getNavItems(_role!),
                ),
              ),
            ),
    );
  }
}
