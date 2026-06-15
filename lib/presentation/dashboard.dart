import 'package:flutter/material.dart';
import 'package:flutter_visitor_app/core/services/notification_service.dart';
import 'home/guest_home_page.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'notification/notification_page.dart';
import '../core/core.dart';
import '../core/helper/responsive_helper.dart';
import '../data/datasources/auth_datasource.dart';
import '../data/models/user_model.dart';
import '../presentation/auth/login_page.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static int selectedIndex = 0;
  // ignore: library_private_types_in_public_api
  static _DashboardState? state;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String? _role;
  UserModel? _user;
  late List<Widget> _widgets = [];

  void changeTab(int index) {
    if (index >= 0 && index < _widgets.length) {
      setState(() {
        _selectedIndex = index;
        Dashboard.selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    Dashboard.state = this;
    var fcm = NotificationService.instance;
    // ini bisa diganti dengan visitor id
    fcm.subscribeToUserTopic("testtopics");
    Dashboard.selectedIndex = 0;
    super.initState();
    _loadRoleAndSetup();
  }

  @override
  void dispose() {
    if (Dashboard.state == this) {
      Dashboard.state = null;
    }
    super.dispose();
  }



  bool _checkIsGuest(String role, UserModel? user) {
    if (user == null) {
      return true;
    }
    final r = role.toLowerCase();
    // Jika role explicitly guest, visitor, atau driver
    if (r == 'guest' || r == 'visitor' || r == 'driver') {
      return true;
    }
    // Jika user memiliki visitor_code atau invitation_code
    if (user.invitationCode != null && user.invitationCode!.isNotEmpty) {
      return true;
    }
    if (user.visitorCode != null && user.visitorCode!.isNotEmpty) {
      return true;
    }

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
      const HistoryPage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    if (_checkIsGuest(role, user)) {
      widgets = [const GuestHomePage(), const ProfilePage()];
    } else if (role == 'operator') {
      widgets = [
        const HomePage(),
        const HistoryPage(),
        const NotificationPage(),
        const ProfilePage(),
      ];
    }

    setState(() {
      _widgets = widgets;
      if (_selectedIndex >= _widgets.length) {
        _selectedIndex = 0;
        Dashboard.selectedIndex = 0;
      }
    });
  }

  List<BottomNavigationBarItem> _getNavItems(String role, UserModel? user) {
    final items = [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home_outlined,
          size: rw(context, 24),
          color: Colors.grey.shade500,
        ),
        activeIcon: Icon(
          Icons.home_rounded,
          size: rw(context, 24),
          color: AppColors.primary500,
        ),
        label: 'home'.tr,
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.history_rounded,
          size: rw(context, 24),
          color: Colors.grey.shade500,
        ),
        activeIcon: Icon(
          Icons.history_rounded,
          size: rw(context, 24),
          color: AppColors.primary500,
        ),
        label: 'history'.tr,
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.notifications_none_rounded,
          size: rw(context, 24),
          color: Colors.grey.shade500,
        ),
        activeIcon: Icon(
          Icons.notifications_rounded,
          size: rw(context, 24),
          color: AppColors.primary500,
        ),
        label: 'notification'.tr,
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

    final scaffold = Scaffold(
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
                  onTap: (value) => setState(() {
                    _selectedIndex = value;
                    Dashboard.selectedIndex = value;
                  }),
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

    if (isGuest) {
      return scaffold;
    }

    if (_selectedIndex != 0) {
      return scaffold;
    }

    return scaffold;
  }
}
