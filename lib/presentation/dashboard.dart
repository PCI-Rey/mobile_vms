import 'package:flutter/material.dart';
import '../../presentation/home/guest_home_page.dart';
import '../../presentation/parking/as_guest/guest_parking_page.dart';
import '../presentation/history/history_page.dart';
import '../presentation/home/home_page.dart';
import 'parking/as_operator/parking_page.dart';
import '../presentation/profile/profile_page.dart';
import '../core/core.dart';
import 'widgets/is_block_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../presentation/auth/login_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  String? _role;
  late List<Widget> _widgets = [];
  late List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetup();
  }

  Future<void> _loadRoleAndSetup() async {
    final user = await AuthDatasource().getAuthData();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final role = user.role ?? '';
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

    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Assets.icons.home.image(height: 24, width: 24),
        activeIcon: Assets.icons.homeSelected.image(height: 24, width: 24),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.parking.image(height: 24, width: 24),
        activeIcon: Assets.icons.parkingSelected.image(height: 24, width: 24),
        label: 'Parking',
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.history.image(height: 24, width: 24),
        activeIcon: Assets.icons.historySelected.image(height: 24, width: 24),
        label: 'History',
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.profile.image(height: 24, width: 24),
        activeIcon: Assets.icons.profileSelected.image(height: 24, width: 24),
        label: 'Profile',
      ),
    ];

    if (role == 'guest') {
      widgets = [
        GuestHomePage(),
        GuestParkingPage(),
        const HistoryPage(),
        const ProfilePage(),
      ];
      items = [
        BottomNavigationBarItem(
          icon: Assets.icons.home.image(height: 24, width: 24),
          activeIcon: Assets.icons.homeSelected.image(height: 24, width: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.parking.image(height: 24, width: 24),
          activeIcon: Assets.icons.parkingSelected.image(height: 24, width: 24),
          label: 'Parking',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.history.image(height: 24, width: 24),
          activeIcon: Assets.icons.historySelected.image(height: 24, width: 24),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.profile.image(height: 24, width: 24),
          activeIcon: Assets.icons.profileSelected.image(height: 24, width: 24),
          label: 'Profile',
        ),
      ];
    } else if (role == 'operator') {
      widgets = [
        const HomePage(),
        ParkingPage(),
        HistoryPage(),
        const ProfilePage(),
      ];
      items = [
        BottomNavigationBarItem(
          icon: Assets.icons.home.image(height: 24, width: 24),
          activeIcon: Assets.icons.homeSelected.image(height: 24, width: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.parking.image(height: 24, width: 24),
          activeIcon: Assets.icons.parkingSelected.image(height: 24, width: 24),
          label: 'Parking',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.history.image(height: 24, width: 24),
          activeIcon: Assets.icons.historySelected.image(height: 24, width: 24),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Assets.icons.profile.image(height: 24, width: 24),
          activeIcon: Assets.icons.profileSelected.image(height: 24, width: 24),
          label: 'Profile',
        ),
      ];
    }

    setState(() {
      _widgets = widgets;
      _navItems = items;

      if (_selectedIndex >= _widgets.length) _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgets),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
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
            items: _navItems,
          ),
        ),
      ),
    );
  }
}