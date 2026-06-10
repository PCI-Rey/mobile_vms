import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import 'alarm_list.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Alarm Alert",
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 16)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(rw(context, 10)),
                margin: EdgeInsets.only(bottom: rh(context, 20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, rh(context, 6)),
                      color: AppColors.primary900.withValues(
                        alpha: 0.2,
                      ), // hitam 8% opacity
                      blurRadius: rw(context, 12),
                      spreadRadius: rw(context, 2),
                    ),
                  ],
                ),

                child: Padding(
                  padding: EdgeInsets.all(rw(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alarm Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rfs(context, 16),
                        ),
                      ),
                      vSpace(context, 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PIE CHART (max width dibatasi)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: rw(context, 150)),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final radius =
                                      constraints.maxWidth /
                                      2; // atau /2.5 tergantung preferensi
                                  return PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          color: Colors.red,
                                          value: 12,
                                          title: '',
                                          radius: radius,
                                        ),
                                        PieChartSectionData(
                                          color: Colors.orange,
                                          value: 9,
                                          title: '',
                                          radius: radius,
                                        ),
                                        PieChartSectionData(
                                          color: Colors.green,
                                          value: 2,
                                          title: '',
                                          radius: radius,
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 0,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          hSpace(context, 50), // jarak antar PieChart dan legend
                          // LEGEND
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LegendItem(
                                  color: Colors.red,
                                  label: "High",
                                  count: 12,
                                ),
                                vSpace(context, 8),
                                LegendItem(
                                  color: Colors.orange,
                                  label: "Medium",
                                  count: 9,
                                ),
                                vSpace(context, 8),
                                LegendItem(
                                  color: Colors.green,
                                  label: "Low",
                                  count: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              vSpace(context, 20),

              // VALUE BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  InfoBox(title: "High", count: 12),
                  InfoBox(title: "Medium", count: 9),
                  InfoBox(title: "Low", count: 2),
                ],
              ),

              vSpace(context, 20),
              const AlarmList(),
            ],
          ),
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(rw(context, 5)),
          width: rw(context, 10),
          height: rw(context, 10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        hSpace(context, 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              vSpace(context, 8),
              Text(
                '$count Person',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final int count;

  const InfoBox({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
        padding: EdgeInsets.symmetric(vertical: rh(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 10)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, rh(context, 5)),
              color: AppColors.primary900.withValues(
                alpha: 0.1,
              ), // hitam 8% opacity
              blurRadius: rw(context, 8),
              spreadRadius: rw(context, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            vSpace(context, 8),
            Text(
              "$count",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rfs(context, 20),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
