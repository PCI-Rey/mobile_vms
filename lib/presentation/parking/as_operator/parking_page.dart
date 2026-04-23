import 'package:flutter/material.dart';
import '../../../../core/components/custom_card.dart';
import '../../../../presentation/parking/as_operator/search_parking_page.dart';
import '../../../../presentation/parking/scan_ticket_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/core.dart';
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
      appBar: AppBar(backgroundColor: Colors.white, title: Text('Parking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    suffixIcon: Icon(Icons.search),
                    showLabel: false,
                    readOnly: true,
                  ),
                ),
              ),
              const SpaceHeight(20),
              Divider(height: 1, thickness: 0.3),
              const SpaceHeight(20),

              // Parking Area Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffE5E7EB).withValues(alpha: 0.8),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary500,
                        child: Icon(FontAwesomeIcons.p, color: Colors.white),
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Area Parking 1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Parking Khusus Mobil',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Available Slots and Parked Vehicles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomStatCard(title: 'Available Slot', value: '20'),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: CustomStatCard(
                      title: 'Parked Vehicles',
                      value: '20',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              // Scan Ticket and View Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomActionCard(
                      label: 'Scan Ticket',
                      icon: Assets.icons.scan.image(height: 24),
                      onTap: () => context.push(ScanTicketPage()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomActionCard(
                      label: 'View',
                      icon: Assets.icons.view.image(height: 24),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SpaceHeight(25),
              Divider(height: 1, thickness: 0.3),
              const SpaceHeight(20),

              // New Parking Section
              Text(
                'New Parking',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),

              // List of New Parking Cards
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return CustomCard(
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
