import 'package:country_flags/country_flags.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/agenda_model.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import '../../presentation/home/evacuate/evacuate_page.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/parking/as_operator/parking_page.dart';
import '../../presentation/home/report/report_page.dart';
import '../../presentation/home/agenda/widgets/visitor_list.dart';
import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/parking/as_guest/guest_parking_page.dart';
import '../../presentation/home/visitor/visitor_page.dart';
import 'agenda/widgets/itenerary_list.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final langCtrl = LanguageController.to;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Assets.icons.id.image(height: 32),
        'menuName': 'access_pass'.tr,
        'onTap': () {
          showAccessPassDialog(
            context: context,
            name: UserController.to.fullName,
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
        'menuName': 'invitation'.tr,
        'onTap': () => context.push(SendInvitationPage()),
      },
      {
        'icon': Assets.icons.approved.image(height: 32),
        'menuName': 'approval'.tr,
        'onTap': () => debugPrint('Delivery clicked'),
      },
      {
        'icon': Assets.icons.healthCheck.image(height: 32),
        'menuName': 'report'.tr,
        'onTap': () => context.push(VisitorReportPage()),
      },
      {
        'icon': Assets.icons.parkingLot.image(height: 32),
        'menuName': 'parking'.tr,
        'onTap': () => context.push(
          UserController.to.user.value?.roleAccess == 'guest'
              ? GuestParkingPage()
              : ParkingPage(),
        ),
      },
      {
        'icon': Assets.icons.location.image(height: 32),
        'menuName': 'visitor'.tr,
        'onTap': () => context.push(VisitorPage()),
      },
      {
        'icon': Assets.icons.alarm.image(height: 32),
        'menuName': 'alarm'.tr,
        'onTap': () => context.push(AlarmListPage()),
      },
      {
        'icon': Assets.icons.evacuate.image(height: 32),
        'menuName': 'evacuate'.tr,
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
                      title: Text(
                        'welcome'.tr,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      subtitle: Obx(
                        () => Text(
                          UserController.to.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: langCtrl.selectedLang.value == 'id' ? 'id' : 'us',
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
                                      child: CountryFlag.fromCountryCode(
                                        code.toUpperCase(),
                                        height: 20,
                                        width: 28,
                                        shape: RoundedRectangle(10),
                                      ),
                                    );
                                  }).toList(),

                                  onChanged: (value) {
                                    if (value != null) {
                                      langCtrl.changeLanguage(value == 'us' ? 'en' : 'id');
                                    }
                                  },
                                ),
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
                                  Icons.notifications_none_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
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

                  // Menu Grid
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: menuItems[index]['onTap'],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: menuItems[index]['icon'],
                              ),
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  menuItems[index]['menuName'],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Content Area (Date Picker & List)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xffFAFCFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('schedule'.tr, style: TextStyles.headline5),
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
                            debugPrint("Tanggal dipilih: $date");
                          },
                        ),
                        SpaceHeight(10),
                        Divider(height: 2),
                        SpaceHeight(20),

                        // List of Visitor List (Agenda)
                        const VisitorList(),

                        SpaceHeight(20),
                        Text(
                          'active_visit'.tr,
                          style: TextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SpaceHeight(10),

                        // Itinerary List
                        const IteneraryList(),

                        SpaceHeight(20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
