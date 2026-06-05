import 'package:flutter/material.dart';
import '../../../../core/components/components.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../presentation/parking/as_operator/search_result_parking_page.dart';

class SearchParkingPage extends StatefulWidget {
  const SearchParkingPage({super.key});

  @override
  State<SearchParkingPage> createState() => _SearchParkingPageState();
}

class _SearchParkingPageState extends State<SearchParkingPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController platNumberController = TextEditingController();
    TextEditingController parkInTimeController = TextEditingController();
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
            // Plate No.
            CustomTextField(
              controller: platNumberController,
              label: 'Plate No.',
              hintText: 'Plate No.',
            ),
            vSpace(context, 10),

            // Area Parking
            CustomTextField(
              controller: parkInTimeController,
              label: 'Area Parking',
              hintText: 'Area Parking',
            ),
            vSpace(context, 10),

            // Park in Time
            CustomTextField(
              controller: parkInTimeController,
              label: 'Park in Time',
              hintText: 'Park in Time',
            ),
            vSpace(context, 20),

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
