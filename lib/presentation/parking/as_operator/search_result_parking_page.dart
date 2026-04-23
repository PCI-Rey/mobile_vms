import 'package:flutter/material.dart';
import '../../../../core/components/custom_card.dart';
import '../../../core/core.dart';

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
        title: Text('Search'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            CustomTextField(
              controller: searchController,
              label: 'Search',
              hintText: 'Search',
              suffixIcon: Icon(Icons.search),
              showLabel: false,
            ),
            const SpaceHeight(20),
            Divider(height: 1, thickness: 0.3),
            const SpaceHeight(20),
            Text(
              'Result',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SpaceHeight(16.0),

            // List of Search Results
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
    );
  }
}
