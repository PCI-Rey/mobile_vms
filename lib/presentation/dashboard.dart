import 'package:flutter/material.dart';
import 'package:flutter_visitor_app/core/services/notification_service.dart';
import 'home/guest_home_page.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
import 'parking/as_operator/parking_page.dart';
import 'profile/profile_page.dart';
import '../core/core.dart';
import '../core/helper/responsive_helper.dart';
import '../data/datasources/auth_datasource.dart';
import '../data/models/user_model.dart';
import '../presentation/auth/login_page.dart';
import 'package:get/get.dart';
import 'home/invitation/send_invitation_page.dart';
import 'home/invitation/widgets/create_share_link_dialog.dart';
import 'home/invitation/controller/invitation_controller.dart';
import 'auth/controller/language_controller.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
      if (_isMenuExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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

  Widget _buildSpeedDial(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Aligns perfectly centered above the Profile tab (which is index 3 of 4 tabs)
    final double rightPosition = (screenWidth / 8) - 24;
    final double bottomPosition = bottomPadding + rh(context, 85.0);

    final String lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';
    final String shareLinkLabel = lang == 'id' ? 'Bagikan Tautan' : 'Share Link';

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final double value = _expandAnimation.value;

        // Sub-buttons data
        final List<Map<String, dynamic>> menuItems = [
          {
            'label': 'Quick Access',
            'icon': Icons.flash_on_rounded,
            'bgColor': const Color(0xFFFFF4E5),
            'iconColor': const Color(0xFFFF9800),
            'isClickable': true,
            'onTap': () {
              if (!Get.isRegistered<InvitationController>()) {
                Get.put(InvitationController());
              }
              context.push(const SendInvitationPage(initialTab: 2));
            },
            'offsetMultiplier': 2.0,
          },
          {
            'label': shareLinkLabel,
            'icon': Icons.add_link,
            'bgColor': const Color(0xFFF3EEFE),
            'iconColor': const Color(0xFF534AB7),
            'isClickable': true,
            'onTap': () {
              if (!Get.isRegistered<InvitationController>()) {
                Get.put(InvitationController());
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const CreateShareLinkDialog(),
              );
            },
            'offsetMultiplier': 1.0,
          },
          {
            'label': 'invitation'.tr,
            'icon': Icons.calendar_month_outlined,
            'bgColor': const Color(0xFFEAF3DE),
            'iconColor': const Color(0xFF3B6D11),
            'isClickable': true,
            'onTap': () {
              context.push(const SendInvitationPage());
            },
            'offsetMultiplier': 0.0,
          },
        ];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Sub-buttons
            ...menuItems.map((item) {
              final double mult = item['offsetMultiplier'] as double;
              final double itemBottom = bottomPosition + 4 + (48 + 12 + mult * 56) * value;

              return Positioned(
                right: rightPosition + 4,
                bottom: itemBottom,
                child: IgnorePointer(
                  ignoring: !_isMenuExpanded,
                  child: Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.5 + 0.5 * value,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label Card
                          Material(
                            type: MaterialType.transparency,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(context, 10),
                                vertical: rh(context, 6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(rw(context, 8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: rw(context, 6),
                                    offset: Offset(0, rh(context, 2)),
                                  ),
                                ],
                              ),
                              child: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: rfs(context, 12),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          hSpace(context, 10),
                          // Circular Icon Button
                          GestureDetector(
                            onTap: item['isClickable'] as bool
                                ? (item['onTap'] as VoidCallback)
                                : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: item['bgColor'] as Color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: rw(context, 6),
                                    offset: Offset(0, rh(context, 3)),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
                                size: rw(context, 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Primary Floating Action Button
            Positioned(
              right: rightPosition,
              bottom: bottomPosition,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.3),
                        blurRadius: rw(context, 10),
                        offset: Offset(0, rh(context, 4)),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: rw(context, 4),
                        offset: Offset(0, rh(context, 2)),
                      ),
                    ],
                  ),
                  child: RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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

    if (isGuest) {
      return scaffold;
    }

    return Stack(
      children: [
        scaffold,
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final double value = _expandAnimation.value;
            if (value == 0.0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.4 * value),
              ),
            );
          },
        ),
        _buildSpeedDial(context),
      ],
    );
  }
}
