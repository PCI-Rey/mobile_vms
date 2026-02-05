import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SearchResultVisitorPage extends StatefulWidget {
  @override
  State<SearchResultVisitorPage> createState() =>
      _SearchResultVisitorPageState();
}

class _SearchResultVisitorPageState extends State<SearchResultVisitorPage> {
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> visitorList = [
    {
      'name': 'Tommy',
      'company': 'PT. Lorem ipsum',
      'destination': 'Gedung HQ',
      'invitation_code': '928234',
      'date': 'Mon, 26 June 2025',
      'timeRange': '10:00 - 13:00',
      'avatar': Assets.images.avaPerson1.image(height: 40),
      'id': '7E20A56D62B',
    },
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visitorList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final visitor = visitorList[index];
                return VisitorCard(
                  visitorName: visitor['name'],
                  companyName: visitor['company'],
                  destination: visitor['destination'],
                  date: visitor['date'],
                  timeRange: visitor['timeRange'],
                  avatar: visitor['avatar'],
                  idVisitor: visitor['id'],
                  invitationCode: visitor['invitation_code'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
