import 'package:country_flags/country_flags.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'alarm/controller/alarm_controller.dart';
import '../../data/models/agenda_model.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import '../../presentation/home/approval/approval_page.dart';
import '../../presentation/home/evacuate/evacuate_page.dart';
import '../../presentation/home/invitation/as_employee/invitation_list_page.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/parking/as_operator/parking_page.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../presentation/home/agenda/widgets/agenda_slider.dart';
import '../../presentation/home/agenda/widgets/itenerary_list.dart';
import '../../presentation/home/agenda/widgets/quick_approval_list.dart';
import '../../presentation/home/agenda/widgets/visitor_list.dart';
import 'alarm/alarm_list.dart';
import '../../presentation/home/report/report_page.dart';
import '../../presentation/home/visitor/visitor_page.dart';
import '../../presentation/parking/as_guest/guest_parking_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/is_block_page.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLang = 'id';
  bool isBlocked = false;

  final List<AgendaModel> agendaList = [
    AgendaModel(
      id: '1',
      jenis: 'Agenda Kedatangan',
      picOrHost: 'Jhon',
      destination: 'Gedung HQ',
      visitStart: DateTime(2025, 6, 26, 10, 0),
      visitEnd: DateTime(2025, 6, 26, 13, 0),
      visitors: [],
    ),
    AgendaModel(
      id: '2',
      jenis: 'Meeting Internal',
      picOrHost: 'Sarah',
      destination: 'Gedung Operasional',
      visitStart: DateTime(2025, 6, 27, 14, 0),
      visitEnd: DateTime(2025, 6, 27, 16, 0),
      visitors: [],
    ),
  ];

  int _currentCarouselIndex = 0;
  String? _role;
  Future<void> _loadRoleAndSetup() async {
    final user = await AuthDatasource().getAuthData();
    if (!mounted) return;

    final role = user!.role ?? '';
    setState(() {
      _role = role;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetup();
    // AlarmController loads data on init, so no need to explicitly call load here
    // unless we want to refresh it.
    if (Get.isRegistered<AlarmController>()) {
      Get.find<AlarmController>().loadAlarms();
    } else {
      Get.put(AlarmController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Assets.icons.id.image(height: 32),
        'menuName': 'Access Pass',
        'onTap': () {
          showAccessPassDialog(
            context: context,
            name: 'Tommy',
            date: 'Mon, 19 Jul 2025',
            time: '10:00 - 13:00',
            invitationCode: '729038',
            cardNumber: '6789209930',
            vehiclePlateNo: 'B1245K',
            parkingSlot: 'Slot A1',
            buildingName: 'Gedung HQ',
            visitorId: '7E20A56D62B',
            profileImagePath: 'assets/images/ava_person1.png', // optional
            isTracked: true,
            isLowBattery: true,
          );
        },
      },
      {
        'icon': Assets.icons.invitation.image(height: 32),
        'menuName': 'Invitation',
        'onTap': () => context.push(InvitationListPage()),
      },
      {
        'icon': Assets.icons.approved.image(height: 32),
        'menuName': 'Approval',
        'onTap': () => context.push(ApprovalPage()),
      },
      {
        'icon': Assets.icons.healthCheck.image(height: 32),
        'menuName': 'Report',
        'onTap': () => context.push(VisitorReportPage()),
      },
      {
        'icon': Assets.icons.parkingLot.image(height: 32),
        'menuName': 'Parking',
        'onTap': () =>
            context.push(_role == 'guest' ? GuestParkingPage() : ParkingPage()),
      },
      {
        'icon': Assets.icons.location.image(height: 32),
        'menuName': 'Visitor',
        'onTap': () => context.push(VisitorPage()),
      },
      {
        'icon': Assets.icons.alarm.image(height: 32),
        'menuName': 'Alarm',
        'onTap': () => context.push(AlarmListPage()),
      },
      {
        'icon': Assets.icons.evacuate.image(height: 32),
        'menuName': 'Evacuate',
        'onTap': () => context.push(EvacuatePage()),
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF72B9FF),
                  Color(0xFF1976D2),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CustomCircleImage(
                        image: Assets.images.avaPerson1.image(
                          fit: BoxFit.cover,
                        ),
                        size: 40,
                      ),
                      title: const Text(
                        'Welcome,',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Tom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedLang,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                style: const TextStyle(color: Colors.black),
                                isDense: true,

                                selectedItemBuilder: (BuildContext context) {
                                  return ['us', 'id'].map<Widget>((
                                    String value,
                                  ) {
                                    return CountryFlag.fromCountryCode(
                                      value.toUpperCase(),
                                      height: 20,
                                      width: 28,
                                      shape: RoundedRectangle(10),
                                    );
                                  }).toList();
                                },

                                items: ['us', 'id'].map((code) {
                                  return DropdownMenuItem<String>(
                                    value: code,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CountryFlag.fromCountryCode(
                                          code.toUpperCase(),
                                          height: 20,
                                          width: 28,
                                          shape: RoundedRectangle(10),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(code.toUpperCase()),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedLang = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showNotificationDialog(context);
                                },
                                child: Icon(
                                  FontAwesomeIcons.bell,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFAFCFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Schedule', style: TextStyles.headline5),
                        DatePicker(
                          DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          daysCount: 30,
                          selectionColor: Colors.blue,
                          selectedTextColor: Colors.white,
                          dayTextStyle: const TextStyle(fontSize: 12),
                          dateTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          monthTextStyle: const TextStyle(fontSize: 10),
                          onDateChange: (date) {
                            print("Tanggal dipilih: $date");
                          },
                        ),
                        SpaceHeight(10),
                        Divider(height: 2),
                        SpaceHeight(20),

                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 160),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              bool isTabletOrDesktop = screenWidth >= 600;

                              if (isTabletOrDesktop) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: menuItems.map((menu) {
                                      return Flexible(
                                        child: GestureDetector(
                                          onTap: menu['onTap'],
                                          child: CircleMenu(
                                            image: menu['icon'],
                                            menuName: menu['menuName'],
                                            size: 80,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              } else {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: GridView.builder(
                                    itemCount: menuItems.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          mainAxisSpacing:
                                              16, // Increased from 2
                                          crossAxisSpacing:
                                              8, // Increased from 5
                                          childAspectRatio:
                                              0.8, // Reduced from 1 to give more height
                                        ),
                                    itemBuilder: (context, index) {
                                      final menu = menuItems[index];
                                      return GestureDetector(
                                        onTap: menu['onTap'],
                                        child: CircleMenu(
                                          image: menu['icon'],
                                          menuName: menu['menuName'],
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        Divider(height: 10),

                        SpaceHeight(20),
                        Text(
                          'Active Visit',
                          style: TextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SpaceHeight(10),
                        AgendaSlider(),

                        SpaceHeight(20),
                        Divider(height: 10),

                        SpaceHeight(10),
                        VisitorList(),

                        SpaceHeight(20),
                        Divider(height: 10),

                        SpaceHeight(20),
                        AlarmList(),

                        SpaceHeight(20),
                        QuickApprovalList(),

                        SpaceHeight(20),
                        IteneraryList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Block overlay
          if (isBlocked) BlockedOverlay(),
        ],
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () => setState(() => isBlocked = true),
        child: FloatingActionButton.small(
          backgroundColor: Colors.red,
          child: const Icon(Icons.lock, color: Colors.white),
          onPressed: () {
            setState(() => isBlocked = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hold to block screen')),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
