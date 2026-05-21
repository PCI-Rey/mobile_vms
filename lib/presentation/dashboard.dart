import 'package:flutter/material.dart';
import 'package:flutter_visitor_app/core/services/notification_service.dart';
import 'home/guest_home_page.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
import 'parking/as_operator/parking_page.dart';
import 'profile/profile_page.dart';
import '../core/core.dart';
import '../core/helper/responsive_helper.dart';
// import 'widgets/is_block_page.dart';
import '../data/datasources/auth_datasource.dart';
import '../data/models/user_model.dart';
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
  UserModel? _user;
  late List<Widget> _widgets = [];

  @override
  void initState() {
    var fcm = NotificationService.instance;
    // ini bisa diganti dengan visitor id
    fcm.subscribeToUserTopic("testtopics");
    super.initState();
    _loadRoleAndSetup();
  }

  bool _checkIsGuest(String role, UserModel? user) {
    if (user == null) return true;
    final r = role.toLowerCase();
    // Jika role explicitly guest, visitor, atau driver
    if (r == 'guest' || r == 'visitor' || r == 'driver') return true;
    // Jika user memiliki visitor_code atau invitation_code
    if (user.invitationCode != null && user.invitationCode!.isNotEmpty)
      return true;
    if (user.visitorCode != null && user.visitorCode!.isNotEmpty) return true;

    // Default fallback: semua role yang bukan role internal employee dianggap guest/visitor
    final employeeRoles = [
      'operator',
      'employee',
      'admin',
      'superadmin',
      'staff',
    ];
    if (!employeeRoles.contains(r)) {
      return true;
    }
    return false;
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
      _user = user;
    });

    _setupByRole(role, user);
  }

  void _setupByRole(String role, UserModel user) {
    List<Widget> widgets = [
      const HomePage(),
      ParkingPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    if (_checkIsGuest(role, user)) {
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

  List<BottomNavigationBarItem> _getNavItems(String role, UserModel? user) {
    final items = [
      BottomNavigationBarItem(
        icon: Assets.icons.home.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        activeIcon: Assets.icons.homeSelected.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        label: 'home'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.parking.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        activeIcon: Assets.icons.parkingSelected.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        label: 'parking'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.history.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        activeIcon: Assets.icons.historySelected.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        label: 'history'.tr,
      ),
      BottomNavigationBarItem(
        icon: Assets.icons.profile.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        activeIcon: Assets.icons.profileSelected.image(
          height: rw(context, 24),
          width: rw(context, 24),
        ),
        label: 'profile'.tr,
      ),
    ];

    if (_checkIsGuest(role, user)) {
      return [items[0], items[3]];
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isGuest = _checkIsGuest(_role!, _user);

    return Scaffold(
      backgroundColor: isGuest ? const Color(0xFF1976D2) : Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _widgets),
      bottomNavigationBar: isGuest
          ? null
          : Container(
              padding: EdgeInsets.only(bottom: rh(context, 10.0)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rw(context, 20.0)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: rw(context, 10),
                    offset: Offset(0, rh(context, -5)),
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
                  selectedLabelStyle: TextStyle(
                    fontSize: rfs(context, 12),
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(fontSize: rfs(context, 12)),
                  items: _getNavItems(_role!, _user),
                ),
              ),
            ),
    );
  }
}
