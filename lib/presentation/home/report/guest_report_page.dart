import 'package:flutter/material.dart';
import '../../../core/helper/responsive_helper.dart';

class GuestReportPage extends StatelessWidget {
  const GuestReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report',
          style: TextStyle(fontSize: rfs(context, 20)),
        ),
      ),
      body: Center(
        child: Text(
          'Coming soon',
          style: TextStyle(fontSize: rfs(context, 16)),
        ),
      ),
    );
  }
}

