import 'package:flutter/material.dart';
import '../../../../core/components/custom_card.dart';
import '../../../../presentation/parking/as_operator/search_parking_page.dart';
import '../../../../presentation/parking/scan_ticket_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../widgets/custom_action_card.dart' show CustomActionCard;
import '../widgets/custom_stats_card.dart';

class ParkingPage extends StatefulWidget {
  const ParkingPage({super.key});

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Parking')),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16.0)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  context.push(SearchParkingPage());
                },
                child: IgnorePointer(
                  // Mencegah TextField menerima input
                  child: CustomTextField(
                    controller: searchController,
                    label: 'Search',
                    hintText: 'Search',
                    suffixIcon: const Icon(Icons.search),
                    showLabel: false,
                    readOnly: true,
                  ),
                ),
              ),
              vSpace(context, 20),
              const Divider(height: 1, thickness: 0.3),
              vSpace(context, 20),

              // Parking Area Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffE5E7EB).withValues(alpha: 0.8),
                      spreadRadius: 1,
                      blurRadius: rw(context, 8),
                      offset: Offset(0, rh(context, 3)),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(rw(context, 16.0)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary500,
                        child: const Icon(FontAwesomeIcons.p, color: Colors.white),
                      ),
                      hSpace(context, 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Area Parking 1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rfs(context, 16.0),
                            ),
                          ),
                          Text(
                            'Parking Khusus Mobil',
                            style: TextStyle(
                              fontSize: rfs(context, 14.0),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              vSpace(context, 16.0),

              // Available Slots and Parked Vehicles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: CustomStatCard(title: 'Available Slot', value: '20'),
                  ),
                  hSpace(context, 16.0),
                  const Expanded(
                    child: CustomStatCard(
                      title: 'Parked Vehicles',
                      value: '20',
                    ),
                  ),
                ],
              ),
              vSpace(context, 16.0),

              // Scan Ticket and View Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomActionCard(
                      label: 'Scan Ticket',
                      icon: Assets.icons.scan.image(height: rh(context, 24)),
                      onTap: () => context.push(ScanTicketPage()),
                    ),
                  ),
                  hSpace(context, 16),
                  Expanded(
                    child: CustomActionCard(
                      label: 'View',
                      icon: Assets.icons.view.image(height: rh(context, 24)),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              vSpace(context, 25),
              const Divider(height: 1, thickness: 0.3),
              vSpace(context, 20),

              // New Parking Section
              Text(
                'New Parking',
                style: TextStyle(fontSize: rfs(context, 18.0), fontWeight: FontWeight.bold),
              ),
              vSpace(context, 8.0),

              // List of New Parking Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const CustomCard(
                    image: Icon(Icons.directions_car, color: Colors.white),
                    size: 12,
                    title: 'B62819Y',
                    subtitle: 'Area Parking Slot A1',
                    backgroundIconColor: AppColors.primary500,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
