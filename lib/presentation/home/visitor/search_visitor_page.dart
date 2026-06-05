import 'package:flutter/material.dart';
import '../../../../core/components/components.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../presentation/home/visitor/search_result_visitor_page.dart';

class SearchVisitorPage extends StatefulWidget {
  const SearchVisitorPage({super.key});

  @override
  State<SearchVisitorPage> createState() => _SearchVisitorPageState();
}

class _SearchVisitorPageState extends State<SearchVisitorPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController platNumberController = TextEditingController();
    // TextEditingController areaParkingController = TextEditingController();
    TextEditingController parkInTimeController = TextEditingController();
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
            // Invitation Code
            CustomTextField(
              controller: platNumberController,
              label: 'Invitation Code',
              hintText: 'Invitation Code',
            ),
            vSpace(context, 10),

            // Group Code
            CustomTextField(
              controller: parkInTimeController,
              label: 'Group Code',
              hintText: 'Group Code',
            ),
            vSpace(context, 10),

            // Visit in Time
            CustomTextField(
              controller: parkInTimeController,
              label: 'Visit in Time',
              hintText: 'Visit in Time',
            ),
            vSpace(context, 20),

            // Search Button
            Button.filled(
              onPressed: () {
                context.push(SearchResultVisitorPage());
              },
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}
