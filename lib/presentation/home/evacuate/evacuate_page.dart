import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../presentation/home/evacuate/evacuate_history_page.dart';
import '../../../core/core.dart';
import 'widgets/counter_box.dart';
import 'widgets/progress_bar.dart';
import 'widgets/reaction_group_card.dart';
import 'widgets/reaction_pie_chart.dart';
import '../../widgets/evacuate_overlay.dart';

class EvacuatePage extends StatefulWidget {
  const EvacuatePage({super.key});

  @override
  State<EvacuatePage> createState() => _EvacuatePageState();
}

class _EvacuatePageState extends State<EvacuatePage> {
  Duration duration = const Duration(minutes: 2);
  Timer? timer;
  bool isEvacuateActive = false;

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (duration.inSeconds > 0) {
        setState(() {
          duration = duration - const Duration(seconds: 1);
        });
      } else {
        timer?.cancel();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;

    setState(() {
      duration = const Duration(minutes: 2);
      isEvacuateActive = false;
    });
  }

  void _handleStartEvacuate() {
    setState(() {
      isEvacuateActive = true;
    });
    startTimer();
  }

  void _handleCheckinEvacuate() {
    setState(() => isEvacuateActive = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }

  List<Map<String, dynamic>> groups = [
    {"title": "Finance", "confirmed": 23, "noReaction": 0, "decline": 2},
    {"title": "HR", "confirmed": 10, "noReaction": 3, "decline": 1},
    {"title": "Tax", "confirmed": 10, "noReaction": 3, "decline": 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text("Evacuate"),
              leading: BackButton(),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: Button.filled(
                      onPressed: () {
                        context.push(EvacuateHistoryPage());
                      },
                      label: 'History',
                      color: AppColors.primary500,
                      borderRadius: 12,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: AppColors.grey300, height: 1.0),
              ),
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      formatDuration(duration),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ReactionPieChartTotal(
                    allGroups: groups,
                    showLegend: true,
                    radius: 70,
                  ),
                  const SizedBox(height: 16),

                  ProgressSection(allGroups: groups),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      CounterBox(title: "Visitor", count: 12),
                      CounterBox(title: "Employee", count: 9),
                      CounterBox(title: "Not Reaction", count: 2),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "Reactions per group",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;

                      int columnCount = screenWidth < 600 ? 2 : 3;
                      double spacing = 10;
                      double totalSpacing = spacing * (columnCount - 1);
                      double itemWidth =
                          (screenWidth - totalSpacing) / columnCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: groups.map((group) {
                          return SizedBox(
                            width: itemWidth,
                            child: ReactionGroupCardFromData(group: group),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SpaceHeight(18),
                  Button.filled(
                    onPressed: _handleStartEvacuate,
                    label: 'Start Evacuate',
                  ),
                  const SpaceHeight(10),
                  Button.filledRed(onPressed: stopTimer, label: 'End Evacuate'),
                ],
              ),
            ),
          ),

          // Evacuate Overlay
          if (isEvacuateActive)
            EvacuateOverlay(
              onCheckin: _handleCheckinEvacuate,
              initialDuration: duration,
            ),
        ],
      ),
    );
  }
}
