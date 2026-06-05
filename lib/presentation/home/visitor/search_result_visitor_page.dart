import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

class SearchResultVisitorPage extends StatefulWidget {
  const SearchResultVisitorPage({super.key});

  @override
  State<SearchResultVisitorPage> createState() =>
      _SearchResultVisitorPageState();
}

class _SearchResultVisitorPageState extends State<SearchResultVisitorPage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> visitorList = [
      {
        'name': 'Tommy',
        'company': 'PT. Lorem ipsum',
        'destination': 'Gedung HQ',
        'invitation_code': '928234',
        'date': 'Mon, 26 June 2025',
        'timeRange': '10:00 - 13:00',
        'avatar': Assets.images.avaPerson1.image(height: rw(context, 40)),
        'id': '7E20A56D62B',
      },
    ];

    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Search'),
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visitorList.length,
              separatorBuilder: (context, index) => vSpace(context, 12),
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
