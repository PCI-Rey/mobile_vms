import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'alarm_list.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Alarm Alerzt"),
        leading: BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 6),
                      color: AppColors.primary900.withValues(
                        alpha: 0.2,
                      ), // hitam 8% opacity
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alarm Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PIE CHART (max width dibatasi)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
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

                          const SizedBox(
                            width: 50,
                          ), // jarak antar PieChart dan legend
                          // LEGEND
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                LegendItem(
                                  color: Colors.red,
                                  label: "High",
                                  count: 12,
                                ),
                                SizedBox(height: 8),
                                LegendItem(
                                  color: Colors.orange,
                                  label: "Medium",
                                  count: 9,
                                ),
                                SizedBox(height: 8),
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
              const SizedBox(height: 20),

              // VALUE BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  InfoBox(title: "High", count: 12),
                  InfoBox(title: "Medium", count: 9),
                  InfoBox(title: "Low", count: 2),
                ],
              ),

              SpaceHeight(20),
              AlarmList(),
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
          margin: EdgeInsets.all(5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Text(
              '$count Person',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              color: AppColors.primary900.withValues(
                alpha: 0.1,
              ), // hitam 8% opacity
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
