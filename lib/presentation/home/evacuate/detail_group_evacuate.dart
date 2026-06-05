import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import 'widgets/counter_box.dart';
import 'widgets/progress_bar.dart';
import 'widgets/reaction_pie_chart.dart';

class DetailGrupEvacuatePage extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const DetailGrupEvacuatePage({super.key, required this.groupData});

  @override
  State<DetailGrupEvacuatePage> createState() => _DetailGrupEvacuatePageState();
}

class _DetailGrupEvacuatePageState extends State<DetailGrupEvacuatePage> {
  @override
  Widget build(BuildContext context) {
    final String groupTitle = widget.groupData['title'] ?? 'Unknown Group';
    final int confirmed = widget.groupData['confirmed'] ?? 0;
    final int noReaction = widget.groupData['noReaction'] ?? 0;
    final int decline = widget.groupData['decline'] ?? 0;
    final int totalCount = confirmed + noReaction + decline;

    List<Map<String, dynamic>> groups = [
      {"title": "Finance", "confirmed": 23, "noReaction": 0, "decline": 2},
      {"title": "HR", "confirmed": 10, "noReaction": 3, "decline": 1},
      {"title": "Tax", "confirmed": 10, "noReaction": 3, "decline": 1},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Evacuate $groupTitle",
          style: TextStyle(fontSize: rfs(context, 18)),
        ),
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(rw(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: CounterBox(title: "Total $groupTitle", count: totalCount),
            ),

            vSpace(context, 16),

            ReactionPieChartTotal(
              allGroups: groups,
              showLegend: true,
              radius: rw(context, 70),
            ),

            ProgressSection(allGroups: groups),
            vSpace(context, 16),
          ],
        ),
      ),
    );
  }
}
