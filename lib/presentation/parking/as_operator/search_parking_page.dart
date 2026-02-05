import 'package:flutter/material.dart';
import '../../../../core/components/components.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../presentation/parking/as_operator/search_result_parking_page.dart';

class SearchParkingPage extends StatefulWidget {
  @override
  State<SearchParkingPage> createState() => _SearchParkingPageState();
}

class _SearchParkingPageState extends State<SearchParkingPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController platNumberController = TextEditingController();
    TextEditingController areaParkingController = TextEditingController();
    TextEditingController parkInTimeController = TextEditingController();
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
            // Plate No.
            CustomTextField(
              controller: platNumberController,
              label: 'Plate No.',
              hintText: 'Plate No.',
            ),
            SpaceHeight(10),

            // Area Parking
            CustomTextField(
              controller: parkInTimeController,
              label: 'Area Parking',
              hintText: 'Area Parking',
            ),
            SpaceHeight(10),

            // Park in Time
            CustomTextField(
              controller: parkInTimeController,
              label: 'Park in Time',
              hintText: 'Park in Time',
            ),
            SpaceHeight(20),

            // Search Button
            Button.filled(
              onPressed: () {
                context.push(SearchResultParkingPage());
              },
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}
