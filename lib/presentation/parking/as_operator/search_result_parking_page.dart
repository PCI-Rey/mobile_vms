import 'package:flutter/material.dart';
import '../../../../core/components/custom_card.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

class SearchResultParkingPage extends StatefulWidget {
  const SearchResultParkingPage({super.key});

  @override
  State<SearchResultParkingPage> createState() =>
      _SearchResultParkingPageState();
}

class _SearchResultParkingPageState extends State<SearchResultParkingPage> {
  final List<Map<String, String>> searchResults = [
    {'plateNo': 'B62819Y', 'area': 'Area Parking Slot A1'},
    {'plateNo': 'B62819Y', 'area': 'Area Parking Slot A1'},
    {'plateNo': 'B62819Y', 'area': 'Area Parking Slot A1'},
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Search',
          style: TextStyle(fontSize: rfs(context, 18)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            CustomTextField(
              controller: searchController,
              label: 'Search',
              hintText: 'Search',
              suffixIcon: const Icon(Icons.search),
              showLabel: false,
            ),
            vSpace(context, 20),
            const Divider(height: 1, thickness: 0.3),
            vSpace(context, 20),
            Text(
              'Result',
              style: TextStyle(fontSize: rfs(context, 18.0), fontWeight: FontWeight.bold),
            ),
            vSpace(context, 16.0),

            // List of Search Results
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
    );
  }
}
